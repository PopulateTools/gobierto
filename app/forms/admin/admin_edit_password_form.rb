class Admin::AdminEditPasswordForm
  include ActiveModel::Model

  attr_accessor :admin_id, :password, :password_confirmation
  attr_reader :admin

  validates :admin, :password, presence: true
  validates :password, confirmation: true

  def save
    update_password if valid?
  end

  def admin
    @admin ||= Admin.find_by(id: admin_id)
  end

  private

  def update_password
    @admin.update_attributes(password: password)
  end
end
