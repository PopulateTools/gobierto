class Admin::AdminConfirmationForm
  include ActiveModel::Model

  attr_accessor :email
  attr_reader :admin

  validates :email, :admin, presence: true

  def save
    return false unless valid?

    admin.regenerate_confirmation_token
    deliver_confirmation_email
  end

  def admin
    @admin ||= Admin.find_by(email: email)
  end

  private

  def deliver_confirmation_email
    Admin::AdminMailer.confirmation_instructions(admin).deliver_later
  end
end
