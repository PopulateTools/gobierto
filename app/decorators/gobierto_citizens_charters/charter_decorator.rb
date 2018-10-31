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

    def available_periods(period_interval)
      object.editions.where(period_interval: period_interval).group(:period, :period_interval).select(:period, :period_interval).order(period: :desc).map(&:to_s).uniq
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

    def progress_history
      grouped_periods = object.editions.group_by_period_interval(reference_edition.period_interval).count
      last_periods = CollectionDecorator.new(grouped_periods.sort_by { |k, _| k[0] }.last(10), decorator: ::GobiertoCitizensCharters::EditionIntervalDecorator)

      last_periods.map do |period_data|
        { date: period_data.sparkline_period,
          value: CharterDecorator.new(object, opts: { reference_edition: period_data.edition }).progress }
      end
    end
  end
end
