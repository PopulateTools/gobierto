# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Invitation < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(start_date: :desc, end_date: :asc, title: :asc) }
    scope :between_dates, lambda { |start_date, end_date|
      if start_date && end_date
        where("start_date >= ? AND end_date <= ?", start_date, end_date)
      elsif start_date
        where("start_date >= ?", start_date)
      elsif end_date
        where("end_date <= ?", end_date)
      end
    }

    default_scope { sorted }

    validates :person, :title, :start_date, :end_date, presence: true
    validates :slug, uniqueness: { scope: :site }

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
