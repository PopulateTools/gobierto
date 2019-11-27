# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Dataset < ApplicationRecord
    include GobiertoCommon::Sluggable

    belongs_to :site

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

    private

    def internal_rails_class_name
      @internal_rails_class_name ||= "site_id_#{site.id}_table_#{table_name}".classify
    end
  end
end
