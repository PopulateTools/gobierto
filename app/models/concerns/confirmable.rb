module Confirmable
  extend ActiveSupport::Concern

  included do
    scope :confirmed, -> { where(confirmation_token: nil) }
  end

  def confirmed?
    confirmation_token.blank?
  end

  def confirm!
    return true if confirmed?

    update_columns(confirmation_token: nil)
  end
end
