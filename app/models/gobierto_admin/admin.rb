require_dependency "gobierto_admin"

module GobiertoAdmin
  class Admin < ApplicationRecord
    include Authentication::Authenticable
    include Authentication::Confirmable
    include Authentication::Invitable
    include Authentication::Recoverable
    include Session::Trackable

    EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

    has_many :admin_sites, dependent: :destroy
    has_many :sites, through: :admin_sites

    has_many :permissions, dependent: :destroy
    has_many :global_permissions, class_name: "Permission::Global"

    has_many :gobierto_development_permissions, class_name: "Permission::GobiertoDevelopment"
    has_many :gobierto_budgets_permissions, class_name: "Permission::GobiertoBudgets"
    has_many :gobierto_budget_consultations_permissions, class_name: "Permission::GobiertoBudgetConsultations"
    has_many :gobierto_people_permissions, class_name: "Permission::GobiertoPeople"

    has_many :census_imports

    before_create :set_god_flag

    validates :email, uniqueness: true

    scope :sorted, -> { order(created_at: :desc) }
    scope :god,    -> { where(god: true) }
    scope :active, -> { confirmed.where.not(authorization_level: authorization_levels[:disabled]) }

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

    def destroy
      return super unless god?

      print "Do you REALLY want to destroy the God Admin ##{id}? [Yes/No]: "
      return "Skipping deletion" unless gets.chomp == "Yes"

      super
    end

    def managing_user?
      god? || manager?
    end

    private

    def set_god_flag
      self.god = true unless self.class.unscoped.god.exists?

      # Always return successfully to avoid halting execution.
      true
    end
  end
end
