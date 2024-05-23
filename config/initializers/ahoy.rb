# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
    # disables automatic linking of visits and users
  end

  def visit
    unless defined?(@visit)
      if ahoy.send(:existing_visit_token) || ahoy.instance_variable_get(:@visit_token)
        # find_by raises error by default with Mongoid when not found
        @visit = visit_model.where(visit_token: ahoy.visit_token, site: ahoy.site).take if ahoy.visit_token
      elsif !Ahoy.cookies? && ahoy.visitor_token
        @visit = visit_model.where(visitor_token: ahoy.visitor_token, site: ahoy.site).where(started_at: Ahoy.visit_duration.ago..).order(started_at: :desc).first
      else
        @visit = nil
      end
    end
    @visit
  end

  def track_visit(data)
    super(data.merge(site_id: ahoy.site&.id))
  end
end

Ahoy.mask_ips = true
Ahoy.cookies = :none
Ahoy.job_queue = :event_creators

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
