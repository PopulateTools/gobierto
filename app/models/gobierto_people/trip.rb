# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Trip < ApplicationRecord

    include GobiertoCommon::Metadatable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(start_date: :desc) }

    validates :person, :title, :start_date, :end_date, presence: true

    metadata_attributes(
      :food_expenses,
      :accomodation_expenses,
      :transport_expenses,
      :other_expenses,
      :total_expenses,
      :company,
      :comments,
      :original_destinations_attribute,
      :purpose
    )

    def destinations
      destinations_meta["destinations"] if destinations_meta
    end

    def duration_dates
      [start_date, end_date]
    end

  end
end
