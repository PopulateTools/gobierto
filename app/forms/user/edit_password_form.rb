# frozen_string_literal: true

class User::EditPasswordForm < BaseForm

  attr_accessor :user_id, :password, :password_confirmation, :site
  attr_reader :user

  validates :user, :password, presence: true
  validates :password, confirmation: true

  def save
    update_password if valid?
  end

  def user
    @user ||= site.users.find_by(id: user_id)
  end

  private

  def update_password
    @user.update_attributes(password: password)
  end
end
