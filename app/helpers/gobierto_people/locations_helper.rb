module GobiertoPeople
  module LocationsHelper
    def external_location_service_url(location)
      "https://www.google.com/maps/place/#{location.lat},#{location.lng}"
    end
  end
end
