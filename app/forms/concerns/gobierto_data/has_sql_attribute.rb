# frozen_string_literal: true

module GobiertoData
  module HasSqlAttribute
    extend ActiveSupport::Concern

    included do
      attr_accessor :sql

      validate :sql_validation
    end

    def sql_validation
      return if site.blank? || sql.blank?

      query_test = Connection.execute_query(site, "explain #{sql}")
      if query_test.is_a?(Hash) && query_test.has_key?(:errors)
        errors.add(:sql, query_test[:errors].map { |error| error[:sql] }.join("\n"))
      end
    end
  end
end
