# frozen_string_literal: true

module GobiertoAdmin
  class AdminNewPasswordForm < BaseForm

    attr_accessor :email
    attr_reader :admin

    validates :email, :admin, presence: true

    def save
      return false unless valid?

      admin.regenerate_reset_password_token
      deliver_reset_password_email
    end

    def admin
      @admin ||= Admin.find_by(email: email)
    end

    private

    def deliver_reset_password_email
      AdminMailer.reset_password_instructions(admin).deliver_later
    end
  end
end
