# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Invitation < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(start_date: :desc, end_date: :asc, title: :asc) }

    default_scope { sorted }

    validates :person, :organizer, :title, :start_date, :end_date, presence: true

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
