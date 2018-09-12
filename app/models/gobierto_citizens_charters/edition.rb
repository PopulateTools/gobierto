# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Edition < ApplicationRecord

    PERIOD_INTERVAL_DATA = {
      year: ->(date) { { year: date.year } },
      quarter: ->(date) { { quarter: (date.month / 4) + 1, year: date.year } },
      month: ->(date) { { month: date.month, year: date.year } },
      week: ->(date) { { week: date.strftime("%W").to_i, year: date.year } }
    }.freeze

    belongs_to :commitment

    enum period_interval: PERIOD_INTERVAL_DATA.keys

    def proportion
      return nil if percentage.blank? && [value, max_value].any?(&:blank?)

      percentage || value / max_value
    end

    def period_values
      PERIOD_INTERVAL_DATA[period_interval.to_sym].call(period)
    end

    def period_start
      period.utc.send("at_beginning_of_#{period_interval}")
    end

    def period_end
      period.utc.send("at_end_of_#{period_interval}")
    end

    def to_s
      period_values.values.join("-")
    end
  end
end
