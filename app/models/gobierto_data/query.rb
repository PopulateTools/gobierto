# frozen_string_literal: true

require_dependency "gobierto_data"

module GobiertoData
  class Query < ApplicationRecord
    belongs_to :dataset
    belongs_to :user
    has_many :visualizations, dependent: :destroy

    translates :name

    validates :dataset, :user, :name, presence: true
    validate :sql_validation
    delegate :site, to: :dataset

    def result
      Connection.execute_query(site, sql)
    end

    private

    def sql_validation
      return if sql.blank?

      query_test = Connection.execute_query(site, "explain #{sql}", include_stats: false)
      if query_test.has_key? :errors
        errors.add(:sql, query_test[:errors].map { |error| error[:sql] }.join("\n"))
      end
    end
  end
end
