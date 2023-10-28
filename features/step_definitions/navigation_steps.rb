When("I visit app's root URL") do
  @driver.get 'http://127.0.0.1:4567'
end

When("I visit app's root URL with the program param set to {string}") do |program|
  @driver.get "http://127.0.0.1:4567?program=#{::URI::Parser.new.escape(program)}"
end

When('I click on {word} link') do |link_text|
  @driver.find_element(:link, link_text).click
end

When('I click on Add new relation link') do
  @driver.find_element(:link, '+ Add new relation').click
end

When('I click on {word} link next to {word} relation name') do |link_text, relation_name|
  relation_section = @driver.find_element(:class, "#{relation_name.downcase}-relation")
  relation_section.find_element(:link, link_text).click
end

When('I navigate to Add new relation page') do
  steps %Q{
    And I click on Edit link
    And I click on Add new relation link
  }
end

When('I navigate to Edit {word} relation page') do |relation_name|
  steps %Q{
    And I click on Edit link
    And I click on Edit link next to #{relation_name} relation name
  }
end

When('I navigate to Drop {word} relation page') do |relation_name|
  steps %Q{
    And I click on Edit link
    And I click on Drop link next to #{relation_name} relation name
  }
end

When('I delete all data from {word} relation') do |relation_name|
  steps %Q{
    And I navigate to Edit #{relation_name} relation page
    And I clear the rows field
    And I click submit button
  }
end
