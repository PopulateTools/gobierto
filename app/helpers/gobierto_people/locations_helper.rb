# frozen_string_literal: true

module GobiertoPeople
  module LocationsHelper
    def external_location_service_url(location)
      "https://www.google.com/maps/place/#{location.lat},#{location.lng}"
    end

    def gobierto_people_past_events_for_people_group_url(people_group)
      case people_group
      when "government"
        gobierto_people_government_party_past_events_path
      when "opposition"
        gobierto_people_opposition_party_past_events_path
      when "executive"
        gobierto_people_executive_category_past_events_path
      end
    end
  end
end
