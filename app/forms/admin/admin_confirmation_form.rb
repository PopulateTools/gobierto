class Admin::AdminConfirmationForm
  include ActiveModel::Model

  attr_accessor :email
  attr_reader :admin

  validates :email, :admin, presence: true

  def save
    send_confirmation_email if valid?
  end

  def admin
    @admin ||= Admin.find_by(email: email)
  end

  private

  def send_confirmation_email
    admin.regenerate_confirmation_token
    deliver_confirmation_email
  end

  protected

  def deliver_confirmation_email
    Admin::AdminMailer.confirmation_instructions(admin).deliver_later
  end
end
