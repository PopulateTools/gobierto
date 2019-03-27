# frozen_string_literal: true

module Authentication::Recoverable
  extend ActiveSupport::Concern

  included do
    scope :recoverable, -> { where.not(reset_password_token: nil) }

    def self.find_by_reset_password_token(reset_password_token)
      recoverable.find_by(reset_password_token: reset_password_token)
    end
  end

  def regenerate_reset_password_token
    update_columns(reset_password_token: self.class.generate_unique_secure_token)
  end

  def recoverable?
    reset_password_token.present?
  end

  def recovered!
    return true unless recoverable?

    update_columns(reset_password_token: nil)
  end
end
