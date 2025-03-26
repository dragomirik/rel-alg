require 'csv'
require 'fileutils'
require 'uri'
require 'yaml'

require 'sinatra'
require 'zip'

require './lib/relation.rb'
require './lib/interpretor.rb'
require './lib/data_container.rb'

DATA_DIRECTORY = ENV['DATA_DIRECTORY'] || './data'
SCHEMA_PATH = "#{DATA_DIRECTORY}/schema.yaml".freeze
RELATION_DATA_PATH = ->(name) { "#{DATA_DIRECTORY}/#{name}.csv" }

def load_data
  unless ::File.exist?(SCHEMA_PATH)
    ::File.open(SCHEMA_PATH, 'w') { |f| f.write({}.to_yaml) }
  end
  data_hash = ::YAML.load(::File.read(SCHEMA_PATH)).map { |name, attrs|
    rel = ::Relation.new(**attrs)
    rel.name = name
    raw_data = ::File.read(RELATION_DATA_PATH.call(name)).lines.map(&:strip).join("\n")
    csv_data = ::CSV.parse(raw_data)
    attrs.each.with_index do |(name, type), i|
      case type
      when :numeric
        csv_data.each { |r| r[i] = (r[i].match?(/\d+\.\d+/) ? r[i].to_f : r[i].to_i) }
      when :date
        csv_data.each { |r| r[i] = Date.parse(r[i]) }
      end
    end
    rel.bulk_insert(csv_data)
    [name, rel]
  }.to_h
  ::DataContainer.new(data_hash)
end

def parse_schema_hash_from_csv(schema_csv)
  ::CSV.parse(schema_csv.strip).map { |(k, v)| [k.to_sym, v.to_sym] }.to_h rescue nil
end

def validate_relation_params(params, old_relation_name = nil)
  errors = {}
  unless params['name'].to_s.size > 0
    errors[:name] = 'Relation name is required'
  end
  schema = ::YAML.load(::File.read(SCHEMA_PATH))
  if (old_relation_name.nil? || old_relation_name != params['name']) && schema[params['name'].to_sym]
    errors[:name] = 'Relation with such name already exists'
  end
  relation_schema = parse_schema_hash_from_csv(params['schema'])
  unless relation_schema
    errors[:schema] = 'Failed to parse relation attributes. Please make sure that the CSV is valid'
    return errors
  end
  if relation_schema.empty?
    errors[:schema] = 'At least one relation attribute is required'
  end
  unless relation_schema.values.all? { |type| ::Attribute::TYPES.include?(type.to_sym) }
    errors[:schema] = 'Unknown attribute type(s) provided'
  end
  ::CSV.parse(params['rows'].strip).each.with_index(1) do |row, row_i|
    if row.size != relation_schema.keys.size
      (errors[:rows] ||= []) << "Error in data row #{row_i}: #{row.size} columns instead of expected #{relation_schema.keys.size}"
    end
    relation_schema.each.with_index do |(name, type), column_i|
      case type
      when :numeric
        unless row[column_i]&.match?(/\d+(\.\d+)?/)
          (errors[:rows] ||= []) << "Error in data row #{row_i}: #{row[column_i]} (#{name}) cannot be parsed into a number"
        end
      when :date
        date = ::Date.parse(row[column_i]) rescue nil
        unless date
          (errors[:rows] ||= []) << "Error in data row #{row_i}: #{row[column_i]} (#{name}) cannot be parsed into a date"
        end
      end
    end
  end
  errors
end

get '/' do
  output = nil
  output = if params['program'].to_s.size > 0
             program_lines = params['program'].lines.map(&:strip)
             begin
               ::Interpretor.new.run(program_lines, load_data.to_h).to_s(reverse: true)
             rescue ::Errors::RelationalAlgebraError => e
               e.message
             end
           end
  erb :index, locals: {
    program: params['program'].to_s,
    input_data: load_data.to_s,
    output_data: output.to_s
  }
end

get '/data' do
  erb :'data/index', locals: { data: load_data.to_h }
end


get '/data/export' do
  ::FileUtils.mkdir_p('tmp')
  zip_file_path = ::File.join('tmp', 'rel_alg_db.zip')
  ::FileUtils.rm(zip_file_path) if ::File.exist?(zip_file_path)
  ::Zip::File.open(zip_file_path, create: true) do |zipfile|
    [SCHEMA_PATH, *Dir[::File.join(DATA_DIRECTORY, '*.csv')]].each do |file_path|
      next unless ::File.exist?(file_path)

      filename = file_path.split('/').last
      zipfile.add(filename, file_path)
    end
  end
  send_file zip_file_path, disposition: :attachment
end

post '/data/import' do
  if (tempfile = params.dig(:file, :tempfile))
    ::FileUtils.rm(SCHEMA_PATH)
    ::FileUtils.rm(Dir[::File.join(DATA_DIRECTORY, '*.csv')])
    ::Zip::File.foreach(tempfile) do |entry|
      entry.extract(::File.join(DATA_DIRECTORY, entry.name))
    end
  end
  redirect to '/data'
end

get '/data/new' do
  erb :'data/new', locals: { name: nil, schema: nil, rows: nil, errors: {} }
end

post '/data/create' do
  if (errors = validate_relation_params(params)).empty?
    schema = ::YAML.load(::File.read(SCHEMA_PATH))
    schema[params['name'].to_sym] = parse_schema_hash_from_csv(params['schema'])
    ::File.open(SCHEMA_PATH, 'w') { |f| f.write(schema.to_yaml) }
    ::File.open(RELATION_DATA_PATH.call(params['name']), 'w') { |f| f.write(params['rows'].strip) }
    redirect to '/data'
  else
    erb :'data/new', locals: {
      name: params['name'],
      schema: params['schema'],
      rows: params['rows'],
      errors: errors
    }
  end
end

get '/data/:relation/edit' do
  erb :'data/edit', locals: {
    original_name: params['relation'],
    name: params['relation'],
    schema: load_data[params['relation'].to_sym].attributes_hash.to_a.map { |attr| attr.to_csv }.join,
    rows: ::File.read(RELATION_DATA_PATH.call(params['relation'])),
    errors: {}
  }
end

post '/data/:relation/update' do
  original_name = params['relation']
  if (errors = validate_relation_params(params, original_name)).empty?
    schema = ::YAML.load(::File.read(SCHEMA_PATH))

    if (new_name = params['name'].strip) && new_name != original_name
      ::FileUtils.mv(RELATION_DATA_PATH.call(original_name), RELATION_DATA_PATH.call(new_name))
      schema[new_name.to_sym] = schema.delete(original_name.to_sym)
    end

    new_schema = ::CSV.parse(params['schema'].strip).to_h.transform_keys(&:to_sym).transform_values(&:to_sym)
    schema[params['name'].strip.to_sym] = new_schema
    ::File.open(SCHEMA_PATH, 'w') { |f| f.write(schema.to_yaml) }

    ::File.open(RELATION_DATA_PATH.call(params['name'].strip), 'w') { |f| f.write(params['rows'].strip) }

    redirect to '/data'
  else
    erb :'data/edit', locals: {
      original_name: original_name,
      name: params['name'],
      schema: params['schema'],
      rows: params['rows'],
      errors: errors
    }
  end
end

get '/data/:relation/delete' do
  erb :'data/delete', locals: {
    name: params['relation'],
    data: load_data[params['relation'].to_sym]
  }
end

post '/data/:relation/destroy' do
  schema = ::YAML.load(::File.read(SCHEMA_PATH))
  schema.delete(params[:relation].to_sym)
  ::File.open(SCHEMA_PATH, 'w') { |f| f.write(schema.to_yaml) }
  ::FileUtils.rm(RELATION_DATA_PATH.call(params[:relation]))
  redirect to '/data'
end
