class User::Verification < ApplicationRecord
  belongs_to :user
  belongs_to :site

  serialize :verification_data, Hash

  scope :sorted, -> { order(created_at: :desc) }

  enum verification_type: { census: 0 }

  def verify!
    true
  end

  def verify_later!
    User::VerificationJob.perform_later(self) if persisted?
  end
end
