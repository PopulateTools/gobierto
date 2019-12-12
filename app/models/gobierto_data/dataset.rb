# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Dataset < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :site
    has_many :queries, dependent: :destroy
    has_many :visualizations, through: :queries

    translates :name

    validates :site, :name, :slug, :table_name, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    def attributes_for_slug
      [name]
    end

    def rails_model
      @rails_model ||= begin
                         return Connection.const_get(internal_rails_class_name) if Connection.const_defined?(internal_rails_class_name)

                         db_config = Connection.db_config(site)
                         return if db_config.blank?

                         Class.new(Connection).tap do |connection_model|
                           Connection.const_set(internal_rails_class_name, connection_model)
                           connection_model.establish_connection(connection_model.db_config(site))
                           connection_model.table_name = table_name
                         end
                       end
    end

    def create_dataset_from_file(file_path, schema_file: nil, export_files: false, csv_separator: ",")
      schema = schema_file.present? ? JSON.parse(File.read(schema_file)).deep_symbolize_keys : {}
      statements = GobiertoData::Datasets::CreationStatements.new(
        dataset: self,
        source_file: file_path,
        schema: schema,
        csv_separator: csv_separator
      )
      if export_files
        base_path = File.join(File.dirname(file_path), File.basename(file_path, ".*"))
        File.open("#{base_path}_schema.json", "w") { |file| file.write(JSON.pretty_generate(statements.schema)) } if schema_file.blank?
        File.open("#{base_path}_script.sql", "w") { |file| file.write(statements.sql_code) }
      end
      Connection.execute_query(site, statements.sql_code)
    end

    private

    def internal_rails_class_name
      @internal_rails_class_name ||= "site_id_#{site.id}_table_#{table_name}".classify
    end
  end
end
