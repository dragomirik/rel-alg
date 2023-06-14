require 'csv'
require 'fileutils'
require 'uri'
require 'yaml'

require 'sinatra'

require './lib/relation.rb'
require './lib/interpretor.rb'

SCHEMA_PATH = './data/schema.yaml'.freeze
RELATION_DATA_PATH = ->(name) { "./data/relations/#{name}.csv" }

def load_data
  ::YAML.load(::File.read(SCHEMA_PATH)).map { |name, attrs|
    rel = ::Relation.new(**attrs)
    rel.name = name
    rel.bulk_insert(::CSV.read(RELATION_DATA_PATH.call(name)))
    [name, rel]
  }.to_h
end

def format_data(data)
  data.map { |rel_name, rel| "#{rel_name}:\n\n#{rel}" }.join("\n\n\n")
end

get '/' do
  erb :index, locals: {
    program: params['program'].to_s,
    input_data: format_data(load_data),
    output_data: params['output'].to_s
  }
end

post '/run' do
  program_lines = params['program'].lines.map(&:strip)
  resulting_data = ::Interpretor.new.run(program_lines, load_data)
  output = format_data(resulting_data.to_h.to_a.reverse)
  redirect to "/?program=#{::URI.escape(params['program'])}&output=#{::URI.escape(output)}"
end

get '/data' do
  erb :'data/index', locals: { data: load_data }
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
