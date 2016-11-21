module Authentication::Confirmable
  extend ActiveSupport::Concern

  included do
    scope :confirmed, -> { where(confirmation_token: nil) }
  end

  def regenerate_confirmation_token
    update_columns(confirmation_token: self.class.generate_unique_secure_token)
  end

  def confirmed?
    confirmation_token.blank?
  end

  def confirm!
    return true if confirmed?

    update_columns(confirmation_token: nil)
  end
end
