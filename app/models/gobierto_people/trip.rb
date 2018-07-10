# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Trip < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(start_date: :desc) }
    scope :between_dates, lambda { |start_date, end_date|
      if start_date && end_date
        where("start_date >= ? AND end_date <= ?", start_date, end_date)
      elsif start_date
        where("start_date >= ?", start_date)
      elsif end_date
        where("end_date <= ?", end_date)
      end
    }

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

    def parameterize
      { person_slug: person.slug, id: id }
    end

    def expenses
      [
        { kind: meta_attribute_translation(:food_expenses), amount: food_expenses },
        { kind: meta_attribute_translation(:accomodation_expenses), amount: accomodation_expenses },
        { kind: meta_attribute_translation(:transport_expenses), amount: transport_expenses },
        { kind: meta_attribute_translation(:other_expenses), amount: other_expenses },
        { kind: meta_attribute_translation(:total_expenses), amount: total_expenses }
      ].reject { |expense| expense[:amount].to_i.zero? }
    end

    def site
      person.site
    end

    def singular_route_key
      :gobierto_people_person_trip
    end

    private

    def meta_attribute_translation(attribute)
      I18n.t "activerecord.attributes.gobierto_people/#{model_name.human.downcase}.#{attribute}"
    end

  end
end
