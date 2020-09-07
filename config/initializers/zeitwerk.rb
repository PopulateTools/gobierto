# frozen_string_literal: true

Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    "es_query_builder" => "ESQueryBuilder",
    "csv_renderer" => "CSVRenderer"
  )

  autoloader.ignore(Rails.root.join("lib/generators/gobierto_module/gobierto_module_generator.rb"))
end
