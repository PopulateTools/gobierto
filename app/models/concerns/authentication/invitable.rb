# frozen_string_literal: true

module Authentication::Invitable
  extend ActiveSupport::Concern

  included do
    scope :invitation, -> { where.not(invitation_sent_at: nil) }
    scope :invitation_pending, -> { invitation.where.not(invitation_token: nil) }
    scope :invitation_accepted, -> { invitation.where(invitation_token: nil) }

    def self.find_by_invitation_token(invitation_token)
      invitation_pending.find_by(invitation_token: invitation_token)
    end
  end

  def regenerate_invitation_token
    update_columns(invitation_token: self.class.generate_unique_secure_token, invitation_sent_at: Time.now)
  end

  def invitation?
    invitation_sent_at.present?
  end

  def invitation_pending?
    invitation? && invitation_token.present?
  end

  def invitation_accepted?
    invitation? && !invitation_pending?
  end

  def accept_invitation!
    return true if invitation_accepted?

    update_columns(invitation_token: nil)
  end
end
