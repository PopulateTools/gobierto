class User::ConfirmationRequestForm
  include ActiveModel::Model

  attr_accessor :email, :site
  attr_reader :user

  validates :email, :site, :user, presence: true

  def save
    send_confirmation_email if valid?
  end

  def user
    @user ||= User.find_by(email: email)
  end

  private

  def send_confirmation_email
    user.regenerate_confirmation_token
    deliver_confirmation_email
  end

  protected

  def deliver_confirmation_email
    User::UserMailer.confirmation_instructions(user, site).deliver_later
  end
end
