class User::Verification < ApplicationRecord
  belongs_to :user
  belongs_to :site

  serialize :verification_data, Hash

  scope :sorted, -> { order(created_at: :desc) }
  scope :by_site, ->(site) { where(site: site) }

  enum verification_type: { census: 0, id_number: 1 }

  def self.current_by_site(site)
    by_site(site).sorted.first
  end

  def verify!
    true
  end

  def verify_later!
    User::VerificationJob.perform_later(self) if persisted?
  end
end
