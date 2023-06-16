require 'fileutils'

ENV['DATA_DIRECTORY'] ||= './tmp/data'

BeforeAll do
  `ruby main.rb > logs/server.test.log &`
end

AfterAll do
  pid = `ps aux | grep puma`.split(' ')[1]
  `kill #{pid}`
end

Before do
  ::FileUtils.mkdir_p(ENV['DATA_DIRECTORY'])
  @driver = Selenium::WebDriver.for :chrome
end

After do
  @driver.quit
  ::FileUtils.rm_r(ENV['DATA_DIRECTORY'])
end
