# rails runner script/xblr/generate_budget_execution_data.rb

puts "[START]"

xblr_dictionary = YAML.load_file("script/xblr/xblr_ids_to_elasticsearch_dictionary.yml")
xblr_file       = File.open("script/xblr/AJ-TrimLoc-2016.xbrl") { |f| Nokogiri::XML(f) }

budget_execution_data = {}

# ==============================================================================
=begin
not_found_count = 0
xblr_dictionary['dictionary'].each do |xblr_budget_line_id, budget_line_info|

  if budget_line_info == 'NOT-FOUND'
    not_found_count += 1
    puts not_found_count
    next
  end

  # Find items in XBLR with this id
  budget_line_execution_nodes = xblr_file.xpath("//*[@contextRef='#{xblr_budget_line_id}']")

  budget_line_has_data = budget_line_execution_nodes.any? do |bl_execution_node|
    bl_execution_node.child.content.to_f > 0
  end

  if budget_line_has_data
    budget_execution_data[xblr_budget_line_id] = {
      'numero_partida'  => budget_line_info['code'],
      'tipo' => budget_line_info['kind'],
      'area' => budget_line_info['area'],
      'datos_ejecucion' => {}
    }

    budget_line_execution_nodes.each do |bl_execution_node|
      name  = bl_execution_node.name
      value = bl_execution_node.child.content.to_f

      budget_execution_data[xblr_budget_line_id]['datos_ejecucion'].store(name, value)
    end
  end
end
=end

# ==============================================================================

def format_bl_execution_data(bl_execution_data)
  formatted_data = {}

  bl_execution_data.each do |execution_data_point|
    name  = execution_data_point[:phase]
    value = execution_data_point[:value]
    formatted_data[name] = value
  end
  formatted_data
end

# Seleccionar todos los nodos de ejecucíon del XBLR
counter = 0
xblr_budget_line_ids = xblr_file.xpath("//@contextRef").map{ |xml_node| xml_node.value }.select{ |budget_line_id| budget_line_id[/^IdContextos.*/] }.uniq


xblr_budget_line_ids.each do |budget_line_id|

  bl_execution_data = xblr_file.xpath("//*[@contextRef='#{budget_line_id}']").map do |execution_node|
    { phase: execution_node.name, value: execution_node.child.content.to_f }
  end

  raise Exception if (bl_execution_data.size != 5)

  bl_execution_data_values = bl_execution_data.map { |data| data[:value] }
  execution_data_available = bl_execution_data_values.any? { |value| value > 0 }

  if execution_data_available
    xblr_dictionary_data = xblr_dictionary['dictionary'][budget_line_id]

    if xblr_dictionary_data != 'NOT-FOUND'
      budget_execution_data[budget_line_id] = {
        'numero_partida'  => xblr_dictionary_data['code'],
        'tipo'            => xblr_dictionary_data['kind'],
        'area'            => xblr_dictionary_data['area'],
        'datos_ejecucion' => format_bl_execution_data(bl_execution_data)
      }
    end
  end
end

# ==============================================================================

puts "[END]"

# Write budget execution data dictionary to yaml file

File.open("script/xblr/budget_execution_data_sample.yml","w") do |file|
   file.write budget_execution_data.to_yaml
end
