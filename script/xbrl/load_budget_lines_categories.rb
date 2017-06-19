# Insert budget line categories in elasticsearch

# rails runner script/xbrl/load_budget_lines_categories.rb script/xbrl/categories.yml

# ------------------------------------------------------------------------------
# Utility constants and functions
# ------------------------------------------------------------------------------

ELASTICSEARCH_INDEX = 'tbi-collections'
ELASTICSEARCH_TYPE  = 'c-categorias-presupuestos-municipales'

def fixture_item_id(fixture_data)
  area = fixture_data['area']
  code = fixture_data['code']
  kind = fixture_data['kind']
  "#{area}/#{code}/#{kind}"
end

# ------------------------------------------------------------------------------
# Start script
# ------------------------------------------------------------------------------

puts "[START]"

categories_file_path  = File.join(Rails.root, ARGV[0])
total_indexed_records = 0
total_created_records = 0

puts "Reading budget lines categories from #{categories_file_path}..."

budget_lines_categories = YAML.load_file(categories_file_path)

budget_lines_categories.each do |key, value|
  result = GobiertoBudgets::SearchEngine.client.index(index: ELASTICSEARCH_INDEX, type: ELASTICSEARCH_TYPE, id: fixture_item_id(value), body: {
    kind: value['kind'],
    area: value['area'],
    name: value['name'],
    code: value['code'],
    parent_code: value['parent_code'],
    level: value['level']
  })

  total_indexed_records += 1 if result['_shards']['successful']
  total_created_records += 1 if result['created']
end

puts "Total indexed records: #{total_indexed_records}/#{budget_lines_categories.keys.size}, created: #{total_created_records}"

puts "[DONE]"
