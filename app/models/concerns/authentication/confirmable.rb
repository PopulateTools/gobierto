module Authentication::Confirmable
  extend ActiveSupport::Concern

  included do
    has_secure_token :confirmation_token

    after_commit :deliver_confirmation_email, on: :create

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

  def deliver_confirmation_email
    return true if respond_to?(:invitation?) && invitation?

    Admin::AdminMailer.confirmation_instructions(self).deliver_later
  end
end
