module Authentication::Recoverable
  extend ActiveSupport::Concern

  included do
    scope :recoverable, -> { where.not(reset_password_token: nil) }
  end

  def regenerate_reset_password_token
    update_columns(reset_password_token: self.class.generate_unique_secure_token,)
  end

  def recoverable?
    reset_password_token.present?
  end

  def recovered!
    return true unless recoverable?

    update_columns(reset_password_token: nil)
  end
end
