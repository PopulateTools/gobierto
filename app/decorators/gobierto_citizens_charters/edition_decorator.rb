# frozen_string_literal: true

module GobiertoCitizensCharters
  class EditionDecorator < BaseDecorator
    def initialize(edition)
      @object = edition
    end

    delegate :period_values, :period_front_params, :period_admin_params, to: :edition

    def edition
      object
    end

    def period_compact
      edition.to_s
    end

    def sparkline_period
      %w(year month).include?(period_interval) ? period_compact : edition.period_start.strftime("%Y-%m-%d")
    end
  end
end
