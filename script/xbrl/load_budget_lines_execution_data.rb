require 'ine/places'

# Insert budget line execution data in elasticsearch
#
# rails runner script/xbrl/load_budget_lines_execution_data.rb <ine_code> <year> <budget_execution_data>
# rails runner script/xbrl/load_budget_lines_execution_data.rb 8077 2016 script/xbrl/budget_execution.yml  // Esplugues
# rails runner script/xbrl/load_budget_lines_execution_data.rb 28079 2016 script/xbrl/budget_execution.yml // Madrid

if ARGV.empty? || ARGV.include?('-h') || ARGV.include?('--help')
  puts "\n------------ HELP ------------"
  puts "    Usage:"
  puts "      Options:"
  puts "        -h or --help       # show this help/usage"
  puts "      Format:"
  puts "        rails runner script/xbrl/load_budget_lines_execution_data.rb <ine_code> <year> <budgets_execution.yml>"
  puts "      Example:"
  puts "        rails runner script/xbrl/load_budget_lines_execution_data.rb 28079 2016 script/xbrl/data/budget_execution.yml"
  puts "------------------------------\n"
  exit
end

# ------------------------------------------------------------------------------
# Utility constants and functions
# ------------------------------------------------------------------------------

BUDGETS_EXECUTION_INDEX = 'budgets-execution-v3'
POPULATION_INDEX        = 'data'
POPULATION_TYPE         = 'population'

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

puts '[START]'

place       = INE::Places::Place.find(ARGV[0])
year        = ARGV[1].to_i
census_year = year - 1
ine_code    = place.id.to_i
budget_execution_file_name = ARGV[2]
budget_execution_file_path = File.join(Rails.root, budget_execution_file_name)

puts "Importing #{year} budgets execution data for #{place.name} (INE code: #{ine_code})..."

# Retrieve place population from elasticsearch population index

begin
  response = GobiertoBudgets::SearchEngine.client.get(index: POPULATION_INDEX, type: POPULATION_TYPE, id: "#{place.id}/#{census_year}")
  population = response['_source']['value']
rescue
  puts "Couldn't retrive population data. Exiting."
  puts '[ABORTED]'
  exit
end

# Read budget execution data from file and import into elasticsearch

puts "Reading budgets execution data from #{budget_execution_file_path}..."

budget_execution = YAML.load_file(budget_execution_file_path)
total_indexed_records = 0
total_created_records = 0

budget_execution.each do |xbrl_id, budget_line_data|

  budget_line_execution_data = budget_line_data['execution_data']

  if budget_line_data['kind'] == 'I'
    kind = 'I'
    amount = budget_line_execution_data['DerechosReconocidosDelEjercicioCorriente'] + budget_line_execution_data['RecaudacionLiquidaDelEjercicioCorriente']
  elsif budget_line_data['kind'] == 'E'
    kind = 'G'
    amount = budget_line_execution_data['ObligacionesReconocidasDelEjercicioCorriente'] + budget_line_execution_data['PagosRealizadosDelEjercicioCorriente']
  end

  id = "#{ine_code}/#{year}/#{budget_line_data['code']}/#{budget_line_data['kind']}"

  result = GobiertoBudgets::SearchEngine.client.index(index: BUDGETS_EXECUTION_INDEX, type: budget_line_data['area'], id: id, body: {
                 ine_code: ine_code,
              province_id: place.province.id.to_i,
              autonomy_id: place.province.autonomous_region_id.to_i,
                     year: year,
               population: population,
                   amount: amount,
                     code: budget_line_data['code'],
                    level: budget_line_data['level'],
                     kind: kind,
    amount_per_inhabitant: amount / population,
              parent_code: budget_line_data['parent_code']
  })

  total_indexed_records += 1 if result['_shards']['successful']
  total_created_records += 1 if result['created']
end

puts "Total indexed records: #{total_indexed_records}/#{budget_execution.keys.size}, created: #{total_created_records}"

puts '[DONE]'
