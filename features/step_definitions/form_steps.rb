require 'csv'
require 'relation'

When('I clear the {word} field') do |field_name|
  find_input(field_name).clear
end

When('I enter {string} into the {word} field') do |input_text, field_name|
  find_input(field_name).send_keys(input_text)
end

When('I enter {string} line into the {word} field') do |input_text, field_name|
  find_input(field_name).send_keys("#{input_text}\n")
end

When('I click submit button') do
  @driver.find_element(:xpath, '//input[@type="submit"]').click
end

When('I enter the schema for {word} relation') do |relation_name|
  step("I enter '#{relation_name}' into the name field")
  relation_schema(relation_name).each do |attr_name, attr_type|
    step("I enter '#{attr_name},#{attr_type}' line into the schema field")
  end
end

When('I enter the data for {word} relation') do |relation_name|
  relation_data(relation_name).each do |row|
    step("I enter '#{row.join(',')}' line into the rows field")
  end
end

When('I should see {string} error next to the {word} field') do |error_msg, field|
  input_group = @driver.find_element(:class, "#{field}-input")
  expect(input_group.find_element(:class, 'errors').text).to include(error_msg)
end
