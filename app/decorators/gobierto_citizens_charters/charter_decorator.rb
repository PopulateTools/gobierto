# frozen_string_literal: true

module GobiertoCitizensCharters
  class CharterDecorator < BaseDecorator
    attr_reader :commitments, :reference_edition, :editions

    def initialize(charter, opts: {})
      @object = charter
      @commitments = charter.commitments.active
      @reference_edition =
        opts[:reference_edition] ||
        charter.editions.where(commitment: @commitments).order(:period).last ||
        GobiertoCitizensCharters::Edition.new(period_interval: "year", period: Date.current)
      @editions = charter.editions.where(commitment: @commitments).of_same_period(@reference_edition)
    end

    def progress
      @progress ||= begin
                      return nil unless editions.exists?

                      editions.progress
                    end
    end

    def previous_period_progress
      @previous_period_progress ||= begin
                                      previous_reference = GobiertoCitizensCharters::Edition.new(
                                        period_interval: reference_edition.period_interval,
                                        period: reference_edition.previous_period_start
                                      )
                                      previous_editions = object.editions.where(commitment: @commitments).of_same_period(previous_reference)
                                      return nil unless previous_editions.exists?

                                      previous_editions.progress
                                    end
    end
  end
end
