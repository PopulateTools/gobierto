# frozen_string_literal: true

module GobiertoCitizensCharters
  class EditionIntervalDecorator < BaseDecorator
    def initialize(edition_interval)
      @object = edition_interval
    end

    delegate :period_values, :period_front_params, :period_admin_params, to: :edition

    def period_interval
      object[0][1]
    end

    def period
      object[0][0]
    end

    def count
      object[1]
    end

    def edition
      @edition ||= GobiertoCitizensCharters::Edition.new(period_interval: period_interval, period: period)
    end

    def period_compact
      GobiertoCitizensCharters::Edition.new(period_interval: period_interval, period: period).to_s
    end
  end
end
