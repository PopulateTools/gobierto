# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Connection < ActiveRecord::Base
    self.abstract_class = true

    class << self
      def execute_query(site, query)
        base_connection_config = connection_config
        return null_query unless (db_conf = db_config(site)).present?

        establish_connection(db_conf)
        connection.execute(query)
      rescue ActiveRecord::StatementInvalid => e
        failed_query(e.message)
      ensure
        establish_connection(base_connection_config)
      end

      def db_config(site)
        site&.gobierto_data_settings&.db_config
      end

      private

      def null_query
        []
      end

      def failed_query(message)
        { error: message }
      end
    end
  end
end
