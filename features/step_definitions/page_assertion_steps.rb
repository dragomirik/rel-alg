Then('I should see the homepage') do
  expect(@driver.find_element(:tag_name, 'h2').text).to eq('Relational Algebra Interpretor')
  expect(@driver.find_element(:tag_name, 'textarea').attribute('value')).to eq('')
  expect(@driver.find_element(:class, 'input-data').text).to start_with('Input Data  Edit')
  expect(@driver.find_element(:class, 'output-container').text).to eq('Output Data')
end

Then("I should see the homepage with {string} program") do |program_text|
  expect(@driver.find_element(:tag_name, 'h2').text).to eq('Relational Algebra Interpretor')
  expect(@driver.find_element(:tag_name, 'textarea').attribute('value')).to include(program_text)
  expect(@driver.find_element(:class, 'input-data').text).to start_with('Input Data  Edit')
  expect(@driver.find_element(:class, 'output-container').text).to start_with('Output Data')
end

Then('I should be on Input data page') do
  expect(@driver.current_url).to end_with('/data')
  expect(@driver.find_element(:tag_name, 'h2').text).to eq(
    'Relational Algebra Interpretor / Input Data'
  )
end

Then('I should be on Add new relation page') do
  expect(@driver.current_url).to end_with('/data/new')
  expect(@driver.find_element(:tag_name, 'h2').text).to eq(
    'Relational Algebra Interpretor / Input Data / New Relation'
  )
  expect(find_input('name').attribute('value')).to eq('')
  expect(find_input('schema').attribute('value')).to eq('')
  expect(find_input('rows').attribute('value')).to eq('')
end

Then('I should be on Add new relation page with the following fields pre-filled:') do |table|
  expect(@driver.current_url).to end_with('/data/create')
  expect(@driver.find_element(:tag_name, 'h2').text).to eq(
    'Relational Algebra Interpretor / Input Data / New Relation'
  )
  table.hashes.first.each do |field_name, value|
    expect(find_input(field_name).attribute('value')).to eq(value)
  end
end

Then('I should be on Edit {word} relation page') do |relation_name|
  expect(@driver.current_url).to match(%r{data/\w+/edit$})
  expect(@driver.find_element(:tag_name, 'h2').text).to eq(
    "Relational Algebra Interpretor / Input Data / Edit #{relation_name}"
  )
  expect(find_input('name').attribute('value')).to eq(relation_name)
  expect(find_input('schema').attribute('value')).to eq(relation_schema(relation_name).to_a.map(&:to_csv).join)
  expect(find_input('rows').attribute('value')).to eq(relation_data(relation_name).map(&:to_csv).join.strip)
end

Then('I should be on Edit {word} relation page with some of the fields changed') do |relation_name|
  expect(@driver.current_url).to match(%r{data/\w+/update$})
  expect(@driver.find_element(:tag_name, 'h2').text).to eq(
    "Relational Algebra Interpretor / Input Data / Edit #{relation_name}"
  )
end

Then('I should be on Drop {word} relation page') do |relation_name|
  expect(@driver.current_url).to match(%r{data/\w+/delete$})
  expect(@driver.find_element(:tag_name, 'h2').text).to eq(
    "Relational Algebra Interpretor / Input Data / Drop #{relation_name}"
  )
  expect(@driver.find_element(:tag_name, 'body').text).to include(
    "Do you really want to permanently delete relation #{relation_name}?"
  )
end

Then('I should see the empty {word} relation') do |relation_name|
  rel = ::Relation.new(**relation_schema(relation_name))
  rel.name = relation_name
  expect(@driver.find_element(:tag_name, 'body').text).to include(rel.to_s)
end

Then('I should see the {word} relation') do |relation_name|
  rel = ::Relation.new(**relation_schema(relation_name))
  rel.name = relation_name
  rel.bulk_insert(relation_data(relation_name))
  expect(@driver.find_element(:tag_name, 'body').text).to include(rel.to_s)
end

Then('I should see a section with the empty {word} relation') do |relation_name|
  rel = ::Relation.new(**relation_schema(relation_name))
  rel.name = relation_name
  section = @driver.find_element(:class, "#{relation_name.downcase}-relation")
  expect(section.text).to include(rel.to_s(with_name: false))
end

Then('I should see a section with the {word} relation') do |relation_name|
  rel = ::Relation.new(**relation_schema(relation_name))
  rel.name = relation_name
  rel.bulk_insert(relation_data(relation_name))
  section = @driver.find_element(:class, "#{relation_name.downcase}-relation")
  expect(section.text).to include(rel.to_s(with_name: false))
end

Then('I should not see a section with the {word} relation') do |relation_name|
  expect { @driver.find_element(:class, "#{relation_name.downcase}-relation") }
    .to raise_error Selenium::WebDriver::Error::NoSuchElementError
end

Then('I should see the following lines within the {word} section:') do |relation_name, table|
  section = @driver.find_element(:class, "#{relation_name.downcase}-relation")
  table.hashes.map { |h| h['line'] }.each do |expected_line|
    expect(section.text).to include(expected_line)
  end
end

Then('I should see the following data output:') do |table|
  output_container = @driver.find_element(:class, 'output-container')
  table.hashes.map { |h| h['line'] }.each do |expected_line|
    expect(output_container.text).to include(expected_line)
  end
end
