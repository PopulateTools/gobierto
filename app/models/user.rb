class User < ApplicationRecord
  include Authentication::Authenticable
  include Authentication::Confirmable
  include Authentication::Recoverable
  include Session::Trackable

  EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

  belongs_to :source_site, class_name: "Site"

  has_many :verifications, class_name: "User::Verification", dependent: :destroy
  has_many :census_verifications, class_name: "User::Verification::CensusVerification"

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
    format: { with: EMAIL_ADDRESS_REGEXP }

  scope :sorted, -> { order(created_at: :desc) }
  scope :by_source_site, ->(source_site) { where(source_site: source_site) }

  def verified?
    census_verified?
  end
end
