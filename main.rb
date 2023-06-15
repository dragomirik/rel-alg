require 'csv'
require 'fileutils'
require 'uri'
require 'yaml'

require 'sinatra'

require './lib/relation.rb'
require './lib/interpretor.rb'
require './lib/data_container.rb'

SCHEMA_PATH = './data/schema.yaml'.freeze
RELATION_DATA_PATH = ->(name) { "./data/#{name}.csv" }

def load_data
  unless ::File.exist?(SCHEMA_PATH)
    ::File.open(SCHEMA_PATH, 'w') { |f| f.write({}.to_yaml) }
  end
  data_hash = ::YAML.load(::File.read(SCHEMA_PATH)).map { |name, attrs|
    rel = ::Relation.new(**attrs)
    rel.name = name
    data = ::CSV.read(RELATION_DATA_PATH.call(name))
    attrs.each.with_index do |(name, type), i|
      case type
      when :numeric
        data.each { |r| r[i] = (r[i].match?(/\d+\.\d+/) ? r[i].to_f : r[i].to_i) }
      when :date
        data.each { |r| r[i] = Date.parse(r[i]) }
      end
    end
    rel.bulk_insert(data)
    [name, rel]
  }.to_h
  ::DataContainer.new(data_hash)
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

get '/data/new' do
  erb :'data/new'
end

post '/data/create' do
  schema = ::YAML.load(::File.read(SCHEMA_PATH))
  relation_schema = ::CSV.parse(params['schema'].strip).to_h.transform_keys(&:to_sym).transform_values(&:to_sym)
  schema[params['name'].to_sym] = relation_schema
  ::File.open(SCHEMA_PATH, 'w') { |f| f.write(schema.to_yaml) }
  ::File.open(RELATION_DATA_PATH.call(params['name']), 'w') { |f| f.write(params['rows'].strip) }
  redirect to '/data'
end

get '/data/:relation/edit' do
  erb :'data/edit', locals: {
    name: params['relation'],
    schema: load_data[params['relation'].to_sym].attributes_hash.to_a.map { |attr| attr.to_csv }.join,
    rows: ::File.read(RELATION_DATA_PATH.call(params['relation']))
  }
end

post '/data/:relation/update' do
  name = params['relation']
  schema = ::YAML.load(::File.read(SCHEMA_PATH))

  if (new_name = params['name'].strip) && new_name != name
    ::FileUtils.mv(RELATION_DATA_PATH.call(name), RELATION_DATA_PATH.call(new_name))
    schema[new_name.to_sym] = schema.delete(name.to_sym)
    name = new_name
  end

  new_schema = ::CSV.parse(params['schema'].strip).to_h.transform_keys(&:to_sym).transform_values(&:to_sym)
  schema[params['relation'].to_sym] = new_schema
  ::File.open(SCHEMA_PATH, 'w') { |f| f.write(schema.to_yaml) }

  new_data_rows = params['rows'].strip
  ::File.open(RELATION_DATA_PATH.call(name), 'w') { |f| f.write(new_data_rows) }

  redirect to '/data'
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
