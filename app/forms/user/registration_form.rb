# frozen_string_literal: true

class User::RegistrationForm < BaseForm

  attr_accessor(
    :email,
    :site,
    :creation_ip,
    :referrer_url,
    :referrer_entity
  )

  validates :site, presence: true
  validates :email, format: { with: User::EMAIL_ADDRESS_REGEXP }

  def save
    return false unless valid?

    send_confirmation_instructions if save_user
  end

  def user
    @user ||= User.new
  end

  private

  def save_user
    @user = user.tap do |user_attributes|
      user_attributes.email = email
      user_attributes.site = site
      user_attributes.creation_ip = creation_ip
      user_attributes.referrer_entity = referrer_entity
      user_attributes.referrer_url = referrer_url
    end

    if @user.valid?
      @user.save

      @user
    else
      promote_errors(@user.errors)

      false
    end
  end

  def send_confirmation_instructions
    user.regenerate_confirmation_token
    deliver_confirmation_email
  end

  protected

  def deliver_confirmation_email
    User::UserMailer.confirmation_instructions(user, site).deliver_later
  end
end
