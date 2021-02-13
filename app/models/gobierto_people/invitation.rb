# frozen_string_literal: true

module GobiertoPeople
  class Invitation < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable
    include BelongsToPersonWithCharge

    belongs_to :department, optional: true
    belongs_to_person_with_historical_charge date_attribute: :start_date

    scope :sorted, -> { order(start_date: :desc, end_date: :asc, title: :asc) }
    scope :between_dates, lambda { |start_date, end_date|
      if start_date && end_date
        where("#{table_name}.start_date >= ? AND #{table_name}.end_date <= ?", start_date, end_date)
      elsif start_date
        where("#{table_name}.start_date >= ?", start_date)
      elsif end_date
        where("#{table_name}.end_date <= ?", end_date)
      end
    }

    default_scope { sorted }

    validates :person, :title, :start_date, :end_date, presence: true

    metadata_attributes(
      :organic_unit,
      :expenses_financed_by_organizer,
      :original_destinations_attribute
    )

    def parameterize
      { person_slug: person.slug, id: id }
    end

  end
end
