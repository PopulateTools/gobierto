# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # disables automatic linking of visits and users
  end

  def visit
    unless defined?(@visit)
      @visit = visit_model.find_by(visit_token: ahoy.visit_token, site: ahoy.site) if ahoy.visit_token
    end
    @visit
  end

  def track_visit(data)
    super(data.merge(site_id: ahoy.site&.id))
  end
end

Ahoy.mask_ips = true
Ahoy.cookies = false

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
