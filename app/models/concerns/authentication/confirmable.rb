module Authentication::Confirmable
  extend ActiveSupport::Concern

  included do
    has_secure_token :confirmation_token

    after_commit :send_confirmation_email, on: :create

    scope :confirmed, -> { where(confirmation_token: nil) }
  end

  def confirmed?
    confirmation_token.blank?
  end

  def confirm!
    return true if confirmed?

    update_columns(confirmation_token: nil)
  end

  private

  def send_confirmation_email
    # TODO. Implement confirmation email delivery logic.

    true
  end
end
