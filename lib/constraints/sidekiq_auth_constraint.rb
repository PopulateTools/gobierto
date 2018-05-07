# frozen_string_literal: true

class SidekiqAuthConstraint

  def self.god_admin?(request)
    admin_id = request.session[:admin_id]

    return false unless admin_id

    current_admin = GobiertoAdmin::Admin.find(admin_id)
    current_admin.god?
  end

  def self.localhost?(request)
    # Rails bug: this should return true instead
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/http/request.rb#L405
    request.local? == 0
  end

end