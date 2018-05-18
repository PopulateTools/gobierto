# frozen_string_literal: true

class User::SessionForm < BaseForm

  attr_accessor(
    :email,
    :site,
    :password,
    :referrer_url
  )

  attr_reader :user

  validates :email, :password, :site, presence: true

  def save
    user.try(:authenticate, password) if valid?
  end

  def user
    @user ||= User.confirmed.find_by(email: email.downcase, site: site)
  end
end
