# frozen_string_literal: true

class SidekiqAuthConstraint

  def self.god_admin?(request)
    admin_id = request.session[:admin_id]

    return false unless admin_id

    current_admin = GobiertoAdmin::Admin.find(admin_id)
    current_admin.god?
  end

end