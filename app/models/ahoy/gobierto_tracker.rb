# frozen_string_literal: true

class Ahoy::GobiertoTracker < Ahoy::Tracker

  def site
    @options[:site]
  end

  protected

  def visit_anonymity_set
    @visit_anonymity_set ||= Digest::UUID.uuid_v5(UUID_NAMESPACE, ["visit", Ahoy.mask_ip(request.remote_ip), request.user_agent, site&.id].join("/"))
  end

  def visitor_anonymity_set
    @visitor_anonymity_set ||= Digest::UUID.uuid_v5(UUID_NAMESPACE, ["visitor", Ahoy.mask_ip(request.remote_ip), request.user_agent, site&.id].join("/"))
  end
end
