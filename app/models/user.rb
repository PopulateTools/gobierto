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
  has_many :id_number_verifications, class_name: "User::Verification::IdNumber"
  has_many :subscriptions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :custom_records, dependent: :destroy, class_name: "GobiertoCommon::CustomUserFieldRecord"
  has_many :contributions, dependent: :destroy, class_name: "GobiertoParticipation::Contribution"
  has_many :flags, dependent: :destroy, class_name: "GobiertoParticipation::Flag"
  has_many :votes, dependent: :destroy, class_name: "GobiertoParticipation::Vote"
  has_many :comment, dependent: :destroy, class_name: "GobiertoParticipation::Comment"

  accepts_nested_attributes_for :custom_records

  validates :email, uniqueness: true

  scope :census_verified, -> { where(census_verified: true) }
  scope :sorted, -> { order(created_at: :desc) }
  scope :by_source_site, ->(source_site) { where(source_site: source_site) }

  enum gender: { male: 0, female: 1 }
  enum notification_frequency: {
    disabled: 0, immediate: 1, hourly: 2, daily: 3, weekly: 4
  }, _suffix: :notifications

  def verified_in_site?(site)
    site_verification(site).present?
  end

  def site_verification(site)
    @user_verifications ||= {}
    @user_verifications[site] ||= census_verifications.find_by(site_id: site.id, user_id: self.id, verified: true)
    @user_verifications[site]
  end
end
