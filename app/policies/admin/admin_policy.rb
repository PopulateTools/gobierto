class Admin::AdminPolicy
  attr_reader :user, :admin

  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def manage_permissions?
    !admin.god?
  end

  def manage_sites?
    !admin.manager? && !admin.god?
  end

  def manage_authorization_levels?
    !admin.god?
  end
end
