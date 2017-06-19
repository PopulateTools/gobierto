# rails runner script/xbrl/create_budget_lines_categories_fixtures.rb script/xbrl/xbrl_dictionary.yml

# ------------------------------------------------------------------------------
# Utility functions
# ------------------------------------------------------------------------------

def fixture_item_name(budget_line_data)
  kind = (budget_line_data['kind'] == 'I') ? 'i' : 'g'
  area = budget_line_data['area']
  code = budget_line_data['code']

  "#{area}_#{code}_#{kind}"
end

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

xbrl_dictionary_path = ARGV[0]

puts '[START]'

puts 'Opening xbrl dictionary...'

xbrl_dictionary = YAML.load_file(File.join(Rails.root, xbrl_dictionary_path))

budget_lines_categories = {}

xbrl_dictionary['dictionary'].each do |xbrl_id, budget_line_data|
  next if budget_line_data == 'NOT-FOUND'
  
  kind = (budget_line_data['kind'] == 'I') ? 'income' : 'expense'
  parent_code = budget_line_data['parent_code']

  budget_lines_categories[fixture_item_name(budget_line_data)] = {
    'kind' => kind,
    'area' => budget_line_data['area'],
    'name' => budget_line_data['name'],
    'code' => budget_line_data['code'],
    'parent_code' => (parent_code ? parent_code.to_i : nil),
    'level' => budget_line_data['level'],
  }
end

categories_file_path = File.join(__dir__, 'categories.yml')
total_categories_written = 0

puts "Writing budget lines categories to #{categories_file_path}..."

File.open(categories_file_path, 'w') do |file|
  file.write "---\n"

  budget_lines_categories.each do |key, value|
    fixture_item = {}
    fixture_item[key] = value

    yaml_representation = fixture_item.to_yaml
    yaml_representation.slice!("---\n")

    file.write "#{yaml_representation}\n"
    total_categories_written += 1
  end
end

puts "Total categories written: #{total_categories_written}"

puts '[DONE]'
