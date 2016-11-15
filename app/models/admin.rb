class Admin < ApplicationRecord
  include Authentication::Authenticable
  include Authentication::Confirmable
  include Authentication::Invitable

  EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

  has_many :admin_sites, dependent: :destroy
  has_many :sites, through: :admin_sites

  has_many :permissions, dependent: :destroy
  has_many :global_permissions, class_name: "Admin::Permission::Global"

  # TODO. Build these associations dynamically.
  has_many :gobierto_development_permissions, class_name: "Admin::Permission::GobiertoDevelopment"
  has_many :gobierto_budgets_permissions, class_name: "Admin::Permission::GobiertoBudgets"

  before_create :set_god_flag

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
    format: { with: EMAIL_ADDRESS_REGEXP }

  scope :sorted, -> { order(created_at: :desc) }
  scope :god,    -> { where(god: true) }
  scope :active, -> { where.not(authorization_level: authorization_levels[:disabled]) }

  enum authorization_level: { regular: 0, manager: 1, disabled: 2 }

  def self.preset
    god.first || god.new(
      email: APP_CONFIG["admins"]["preset_admin_email"],
      name: APP_CONFIG["admins"]["preset_admin_name"],
      password: APP_CONFIG["admins"]["preset_admin_password"]
    )
  end

  def sites
    managing_user? ? Site.all : super
  end

  def update_session_data(remote_ip, timestamp = Time.zone.now)
    update_columns(last_sign_in_ip: remote_ip, last_sign_in_at: timestamp)
  end

  def destroy
    return super unless god?

    print "Do you REALLY want to destroy the God Admin ##{id}? [Yes/No]: "
    return "Skipping deletion" unless gets.chomp == "Yes"

    super
  end

  private

  def managing_user?
    god? || manager?
  end

  def set_god_flag
    self.god = true unless self.class.unscoped.god.exists?

    # Always return successfully to avoid halting execution.
    true
  end
end
