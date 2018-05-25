# frozen_string_literal: true

module GobiertoAdmin
  class UserWelcomeMessageForm < BaseForm

    attr_accessor(
      :id,
      :password,
      :password_confirmation
    )

    validates :user, presence: true

    def save
      deliver_welcome_email if valid?
    end

    def user
      @user ||= User.find_by(id: id).presence || build_user
    end

    def site
      user.site
    end

    private

    def build_user
      User.new
    end

    def deliver_welcome_email
      ::User::UserMailer.welcome(user, site).deliver_later
    end
  end
end
