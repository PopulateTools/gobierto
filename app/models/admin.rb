class Admin < ApplicationRecord
  include Authentication::Authenticable
  include Authentication::Confirmable

  EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

  has_many :admin_sites, dependent: :destroy
  has_many :sites, through: :admin_sites

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
    format: { with: EMAIL_ADDRESS_REGEXP }

  scope :sorted, -> { order(created_at: :desc) }

  enum authorization_level: { regular: 0, manager: 1, disabled: 2 }

  def sites
    return Site.all if manager?

    super
  end

  def update_session_data(remote_ip, timestamp = Time.zone.now)
    update_columns(last_sign_in_ip: remote_ip, last_sign_in_at: timestamp)
  end
end
