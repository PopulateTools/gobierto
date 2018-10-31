# frozen_string_literal: true

module GobiertoCitizensCharters
  class CommitmentDecorator < BaseDecorator
    def initialize(commitment)
      @object = commitment
    end

    def progress_history(reference_edition)
      editions = CollectionDecorator.new(
        object.editions.where(period_interval: reference_edition.period_interval).order(period: :asc).limit(10),
        decorator: ::GobiertoCitizensCharters::EditionDecorator
      )
      editions.map do |edition|
        { date: edition.sparkline_period,
          value: edition.proportion }
      end
    end
  end
end
