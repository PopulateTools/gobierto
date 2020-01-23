# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Dataset < ApplicationRecord
    include GobiertoCommon::Sluggable
    include GobiertoData::Favoriteable

    belongs_to :site
    has_many :queries, dependent: :destroy, class_name: "GobiertoData::Query"
    has_many :visualizations, through: :queries, class_name: "GobiertoData::Visualization"

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

                         db_config = db_config.fetch(:read_db_config, db_config)

                         Class.new(Connection).tap do |connection_model|
                           Connection.const_set(internal_rails_class_name, connection_model)
                           connection_model.establish_connection(db_config)
                           connection_model.table_name = table_name
                         end
                       end
    end

    def load_data_from_file(file_path, schema_file: nil, csv_separator: ",", append: false)
      schema = if schema_file.blank?
                 {}
               elsif schema_file.is_a? Hash
                 schema_file.deep_symbolize_keys
               else
                 JSON.parse(File.read(schema_file)).deep_symbolize_keys
               end
      statements = GobiertoData::Datasets::CreationStatements.new(
        self,
        file_path,
        schema,
        csv_separator: csv_separator,
        append: append,
        use_stdin: true
      )

      query_result = Connection.execute_write_query_from_file_using_stdin(site, statements.sql_code, file_path: file_path)
      touch(:data_updated_at) unless query_result.has_key?(:errors)
      {
        db_result: query_result,
        schema: statements.schema,
        script: statements.transaction_sql_code
      }
    end

    private

    def internal_rails_class_name
      @internal_rails_class_name ||= "site_id_#{site.id}_table_#{table_name}".classify
    end
  end
end
