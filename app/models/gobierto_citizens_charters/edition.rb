# frozen_string_literal: true

require_dependency "gobierto_citizens_charters"

module GobiertoCitizensCharters
  class Edition < ApplicationRecord
    acts_as_paranoid column: :archived_at

    include ActsAsParanoidAliases

    SIGNIFICATIVE_DECIMALS = 1
    PERIOD_INTERVAL_DATA = {
      year: ->(date) { { year: date.year } },
      quarter: ->(date) { { year: date.year, quarter: (date.month / 4) + 1 } },
      month: ->(date) { { year: date.year, month: date.month } },
      week: ->(date) { { year: date.year, week: date.strftime("%W").to_i } }
    }.freeze

    FRONT_PERIOD_INTERVALS = {
      year: "a",
      quarter: "c",
      month: "m",
      week: "s"
    }.freeze

    attr_accessor :admin_id

    belongs_to :commitment, -> { with_archived }
    delegate :site_id, :charter, to: :commitment

    enum period_interval: PERIOD_INTERVAL_DATA.keys

    scope :recent, -> { order(period: :desc) }
    scope :of_same_period, ->(edition) { where(period: (edition.period_start..edition.period_end), period_interval: edition.period_interval) }
    scope :group_by_period_interval, ->(period_interval) { where(period_interval: period_interval).group(Arel.sql("date_trunc('#{ period_interval }', period)"), :period_interval) }

    def proportion
      return nil if percentage.blank? && [value, max_value].any?(&:blank?)

      percentage || 100 * (value / max_value)
    end

    def has_values?
      [value, max_value].all?(&:present?) && (percentage.blank? || percentage.round(SIGNIFICATIVE_DECIMALS) == (100 * (value / max_value)).round(SIGNIFICATIVE_DECIMALS))
    end

    def front_period_interval
      FRONT_PERIOD_INTERVALS[period_interval.to_sym]
    end

    def self.progress
      p_rel = where.not(percentage: nil)
      p_val = where(percentage: nil).where.not(value: nil, max_value: nil)
      (p_rel.sum(:percentage) + p_val.sum("value/max_value") * 100) / (p_rel.count + p_val.count)
    end

    def period_values
      PERIOD_INTERVAL_DATA[period_interval.to_sym].call(period)
    end

    def editions_of_same_period
      self.class.of_same_period(self)
    end

    def period_start
      period.utc.send("at_beginning_of_#{period_interval}")
    end

    def period_end
      period.utc.send("at_end_of_#{period_interval}")
    end

    def previous_period_start
      period_start.send("prev_#{period_interval}")
    end

    def to_s
      period_values.values.join("-")
    end

    def front_period_params
      return {} if [front_period_interval, period].any?(&:blank?)

      { front_period_interval: front_period_interval, period: period_values.values.join("-") }
    end

    def admin_period_params
      return {} if [period_interval, period].any?(&:blank?)

      attributes.slice("period_interval", "period")
    end
  end
end
