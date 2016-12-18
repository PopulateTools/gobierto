class User < ApplicationRecord
  include Authentication::Authenticable
  include Authentication::Confirmable
  include Authentication::Recoverable
  include Session::Trackable
  include User::Subscriber

  EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

  belongs_to :source_site, class_name: "Site"

  has_many :verifications, class_name: "User::Verification", dependent: :destroy
  has_many :census_verifications, class_name: "User::Verification::CensusVerification"
  has_many :subscriptions, dependent: :destroy

  validates :email, uniqueness: true

  scope :sorted, -> { order(created_at: :desc) }
  scope :by_source_site, ->(source_site) { where(source_site: source_site) }

  enum gender: { male: 0, female: 1 }
end
