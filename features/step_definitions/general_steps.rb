require 'fileutils'
require 'selenium-webdriver'

require 'pry'

def relation_schema(relation_name)
  schema = ::YAML.load(::File.read('features/support/files/schema.yaml'))
  schema[relation_name.to_sym]
end

def relation_data(relation_name)
  ::CSV.parse(::File.read("features/support/files/#{relation_name}.csv"))
end

def find_input(name)
  @driver.find_element(:name, name)
end

def with_retry(n_attempts: 2, timeout: 1, &block)
  n_attempts.times do |i|
    begin
      yield
    rescue => e
      raise e if i == n_attempts - 1
      sleep timeout
    end
  end
end

When('I stop at breakpoint') do
  binding.pry
end

Given('there is pre-existing input data') do
  ::FileUtils.cp(Dir['features/support/files/*'], ENV['DATA_DIRECTORY'])
end
