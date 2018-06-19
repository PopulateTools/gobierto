# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Gift < ApplicationRecord

    include GobiertoCommon::Metadatable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(date: :desc, name: :asc) }

    default_scope { sorted }

    validates :name, presence: true

    metadata_attributes :type, :event_name, :delivered_by, :category_name

    def parameterize
      { person_slug: person.slug, id: id }
    end

    def to_path
      url_helpers.gobierto_people_person_gift_path(parameterize)
    end

  end
end
