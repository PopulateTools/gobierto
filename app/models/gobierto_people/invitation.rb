# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Invitation < ApplicationRecord

    include GobiertoCommon::Metadatable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(start_date: :desc, end_date: :asc, title: :asc) }

    default_scope { sorted }

    validates :person, :organizer, :title, :start_date, :end_date, presence: true

    metadata_attributes :organic_unit, :expenses_financed_by_organizer

    def parameterize
      { person_slug: person.slug, id: id }
    end

    def to_path
      url_helpers.gobierto_people_person_invitation_path(parameterize)
    end

  end
end
