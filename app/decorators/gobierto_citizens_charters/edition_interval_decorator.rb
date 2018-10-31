# frozen_string_literal: true

module GobiertoCitizensCharters
  class EditionIntervalDecorator < EditionDecorator
    def initialize(edition_interval)
      @object = edition_interval
    end

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
  end
end
