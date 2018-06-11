# frozen_string_literal: true

module GobiertoPeople
  class InterestGroupRowchartSerializer < ActiveModel::Serializer

    attributes :key, :value, :properties

    def key
      object.name
    end

    def value
      object.events_count
    end

    def properties
      {
        url: url_helpers.gobierto_people_interest_group_url(
          object,
          host: object.site.domain
        )
      }
    end

    private

    def url_helpers
      Rails.application.routes.url_helpers
    end

  end
end
