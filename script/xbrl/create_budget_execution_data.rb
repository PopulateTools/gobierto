# rails runner script/xbrl/create_budget_execution_data.rb script/xbrl/xbrl_dictionary.yml script/xbrl/xbrl_file.xbrl

# ------------------------------------------------------------------------------
# Utility constants and functions
# ------------------------------------------------------------------------------

def format_bl_execution_data(bl_execution_data)
  formatted_data = {}

  bl_execution_data.each do |execution_data_point|
    name  = execution_data_point[:phase]
    value = execution_data_point[:value]
    formatted_data[name] = value
  end
  formatted_data
end

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

puts '[START]'

xbrl_dictionary_path = File.join(Rails.root, ARGV[0])
xbrl_file_path       = File.join(Rails.root, ARGV[1])

puts 'Opening xbrl dictionary and xbrl file...'

xbrl_dictionary = YAML.load_file(xbrl_dictionary_path)
xbrl_file       = File.open(xbrl_file_path) { |f| Nokogiri::XML(f) }

puts 'Creating budget execution data...'

budget_execution_data = {}

# Seleccionar todos los nodos de ejecución del xbrl
counter = 0
xbrl_budget_line_ids = xbrl_file.xpath('//@contextRef').map{ |xml_node| xml_node.value }.select{ |budget_line_id| budget_line_id[/^IdContextos.*/] }.uniq


xbrl_budget_line_ids.each do |budget_line_id|

  bl_execution_data = xbrl_file.xpath("//*[@contextRef='#{budget_line_id}']").map do |execution_node|
    { phase: execution_node.name, value: execution_node.child.content.to_f }
  end

  raise Exception if (bl_execution_data.size != 5)

  bl_execution_data_values = bl_execution_data.map { |data| data[:value] }
  execution_data_available = bl_execution_data_values.any? { |value| value > 0 }

  if execution_data_available
    xbrl_dictionary_data = xbrl_dictionary['dictionary'][budget_line_id]

    if xbrl_dictionary_data != 'NOT-FOUND'
      budget_execution_data[budget_line_id] = {
        'kind'           => xbrl_dictionary_data['kind'],
        'area'           => xbrl_dictionary_data['area'],
        'name'           => xbrl_dictionary_data['name'],
        'code'           => xbrl_dictionary_data['code'],
        'parent_code'    => xbrl_dictionary_data['parent_code'],
        'level'          => xbrl_dictionary_data['level'],
        'execution_data' => format_bl_execution_data(bl_execution_data)
      }
    end
  end
end

puts "Found data for #{budget_execution_data.keys.size} different budget lines."

# Write budget execution data dictionary to yaml file

budget_execution_data_file_path = File.join(__dir__, 'budget_execution.yml')

puts "Writing budget execution data to #{budget_execution_data_file_path}..."

File.open(budget_execution_data_file_path, 'w') do |file|
   file.write budget_execution_data.to_yaml
end

puts '[DONE]'
