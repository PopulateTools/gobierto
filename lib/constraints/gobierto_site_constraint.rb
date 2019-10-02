# frozen_string_literal: true

class GobiertoSiteConstraint
  def matches?(request)
    request.env["gobierto_site"].present?
  end
end
