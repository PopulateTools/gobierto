# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Gift < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(date: :desc, name: :asc) }
    scope :between_dates, lambda { |start_date, end_date|
      if start_date && end_date
        where(date: start_date..end_date)
      elsif start_date
        where("date >= ?", start_date)
      elsif end_date
        where("date <= ?", end_date)
      end
    }

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
