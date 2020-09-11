# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Charge < ApplicationRecord
    include GobiertoCommon::HasExternalId

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
    scope :with_department, ->(department) { where(department: department) if department.present? }
    scope :sorted, -> { order("#{table_name}.start_date ASC NULLS FIRST, #{table_name}.end_date ASC NULLS LAST") }
    scope :reverse_sorted, -> { order("#{table_name}.start_date DESC NULLS LAST, #{table_name}.end_date ASC NULLS FIRST") }

    def self.date_range_sql(params = {})
      date_params = params.symbolize_keys.slice(:start_date, :end_date).compact

      DATE_RANGE_CONDITIONS.slice(*date_params.keys).values.join(" AND ")
    end

    def to_s
      "#{name}#{date_range_to_s}"
    end

    private

    def date_range_to_s
      return if date_range.compact.blank?

      " (#{date_range.join(" - ")})"
    end

    def date_range
      @date_range ||= [start_date&.strftime("%m/%Y"), end_date&.strftime("%m/%Y") || I18n.t("shared.currently")]
    end
  end
end
