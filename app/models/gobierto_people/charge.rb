# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Charge < ApplicationRecord

    DATE_RANGE_CONDITIONS = {
      start_date: "(#{table_name}.end_date IS NULL OR #{table_name}.end_date >= :start_date)",
      end_date: "(#{table_name}.start_date IS NULL OR #{table_name}.start_date <= :end_date)"
    }.freeze

    belongs_to :person
    belongs_to :department

    translates :name

    scope :on_date, ->(date) { between_dates(start_date: date, end_date: date) }
    scope :between_dates, lambda { |params|
      params ||= {}
      where(date_range_sql(params), params)
    }

    def self.date_range_sql(params = {})
      date_params = params.slice(:start_date, :end_date).compact

      DATE_RANGE_CONDITIONS.slice(*date_params.keys).values.join(" AND ")
    end

    def to_s
      name
    end
  end
end
