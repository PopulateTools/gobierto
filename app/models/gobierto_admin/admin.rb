# frozen_string_literal: true

require_dependency "gobierto_admin"

module GobiertoAdmin
  class Admin < ApplicationRecord
    include Authentication::Authenticable
    include Authentication::Invitable
    include Authentication::Recoverable
    include Session::Trackable

    EMAIL_ADDRESS_REGEXP = /\A(.+)@(.+\..+)\z/

    has_many :admin_sites, dependent: :destroy
    has_many :sites, through: :admin_sites

    has_and_belongs_to_many :admin_groups, ->(admin) { where(site_id: admin.sites.pluck(:id)) }, join_table: "admin_groups_admins"
    has_many :permissions, ->(admin) { joins(:admin_group).where(admin_admin_groups: { site_id: admin.sites.pluck(:id) }) }, through: :admin_groups
    has_many :global_permissions, through: :admin_groups, class_name: "Permission::Global", source: :permissions
    has_many :modules_permissions, -> { for_modules }, through: :admin_groups, class_name: "::GobiertoAdmin::GroupPermission"
    has_many :site_options_permissions, -> { for_site_options }, through: :admin_groups, class_name: "GobiertoAdmin::GroupPermission"

    has_many :gobierto_development_permissions, through: :admin_groups, class_name: "Permission::GobiertoDevelopment", source: :permissions
    has_many :gobierto_budgets_permissions, through: :admin_groups, class_name: "Permission::GobiertoBudgets", source: :permissions
    has_many :gobierto_budget_consultations_permissions, through: :admin_groups, class_name: "Permission::GobiertoBudgetConsultations", source: :permissions
    has_many :gobierto_people_permissions, through: :admin_groups, class_name: "Permission::GobiertoPeople", source: :permissions
    has_many :gobierto_plans_permissions, through: :admin_groups, class_name: "Permission::GobiertoPlans", source: :permissions
    has_many :gobierto_plans_projects, class_name: "::GobiertoPlans::Node", dependent: :nullify
    has_many :gobierto_observatory_permissions, through: :admin_groups, class_name: "Permission::GobiertoObservatory", source: :permissions
    has_many :gobierto_participation_permissions, through: :admin_groups, class_name: "Permission::GobiertoParticipation", source: :permissions
    has_many :gobierto_citizens_charters_permissions, through: :admin_groups, class_name: "Permission::GobiertoCitizensCharters", source: :permissions
    has_many :contribution_containers, dependent: :destroy, class_name: "GobiertoParticipation::ContributionContainer"

    has_many :census_imports

    before_create :set_god_flag, :generate_preview_token

    validates :email, uniqueness: true
    validates_associated :permissions

    scope :sorted, -> { order(created_at: :desc) }
    scope :god, -> { where(god: true) }
    scope :active, -> { where.not(authorization_level: authorization_levels[:disabled]) }

    enum authorization_level: { regular: 0, manager: 1, disabled: 2 }

    def self.preset
      god.first || god.new(
        email: APP_CONFIG["admins"]["preset_admin_email"],
        name: APP_CONFIG["admins"]["preset_admin_name"],
        password: Rails.application.secrets.preset_admin_password
      )
    end

    def people_permissions
      permissions.for_people
    end

    def sites_people_permissions
      permissions.for_site_people(site_ids)
    end

    def sites
      if managing_user?
        Site.all
      elsif disabled?
        Site.none
      else
        super
      end
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

    def module_allowed?(module_namespace, site)
      managing_user? || send(module_namespace.underscore + "_permissions").on_site(site).any?
    end

    def module_allowed_action?(module_namespace, site, action)
      managing_user? || send(module_namespace.underscore + "_permissions").on_site(site).where(action_name: action).any?
    end

    def can_customize_site?
      managing_user? || site_options_permissions.exists?(resource_name: :customize)
    end

    def can_edit_vocabularies?
      managing_user? || site_options_permissions.exists?(resource_name: :vocabularies)
    end

    def can_edit_custom_fields?
      managing_user? || site_options_permissions.exists?(resource_name: :custom_fields)
    end

    def can_edit_templates?
      managing_user? || site_options_permissions.exists?(resource_name: :templates)
    end

    private

    def set_god_flag
      self.god = true unless self.class.unscoped.god.exists?

      # Always return successfully to avoid halting execution.
      true
    end

    def generate_preview_token
      self.preview_token = self.class.generate_unique_secure_token
    end
  end
end
