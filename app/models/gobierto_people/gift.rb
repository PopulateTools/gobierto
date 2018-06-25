# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Gift < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(date: :desc, name: :asc) }

    default_scope { sorted }

    validates :name, presence: true

    metadata_attributes :type, :event_name, :delivered_by, :category_name

    def parameterize
      { person_slug: person.slug, id: id }
    end

    def singular_route_key
      :gobierto_people_person_gift
    end

    def site
      person.site
    end

  end
end
