class User::NewPasswordForm
  include ActiveModel::Model

  attr_accessor :email, :site
  attr_reader :user

  validates :email, :site, :user, presence: true

  def save
    return false unless valid?

    user.regenerate_reset_password_token
    deliver_reset_password_email
  end

  def user
    @user ||= User.find_by(email: email)
  end

  private

  def deliver_reset_password_email
    User::UserMailer.reset_password_instructions(user, site).deliver_later
  end
end
