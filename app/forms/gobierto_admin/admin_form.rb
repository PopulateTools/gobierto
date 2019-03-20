# frozen_string_literal: true

module GobiertoAdmin
  class AdminForm < BaseForm

    attr_accessor(
      :id,
      :site,
      :name,
      :email,
      :password,
      :password_confirmation,
      :creation_ip,
      :last_sign_in_at,
      :last_sign_in_ip
    )

    attr_reader :permitted_sites, :sites, :admin_group_ids, :admin_groups
    attr_writer :authorization_level

    delegate :persisted?, to: :admin

    validates :name, :email, :site, presence: true
    validates :email, format: { with: Admin::EMAIL_ADDRESS_REGEXP }
    validates :password, presence: { if: :new_record? }, confirmation: true

    def initialize(attributes = {})
      parsed_attributes = attributes.to_h.with_indifferent_access

      super(parsed_attributes.except(:permitted_sites, :admin_group_ids))

      set_permitted_sites(parsed_attributes)
      set_admin_groups(parsed_attributes)
    end

    def save
      @new_record = admin.new_record?

      return false unless valid?

      if save_admin
        send_invitation if send_invitation?

        admin
      end
    end

    def admin
      @admin ||= Admin.find_by(id: id).presence || build_admin
    end

    def authorization_level
      @authorization_level ||= "regular"
    end

    private

    def build_admin
      Admin.new
    end

    def email_changed?
      @email_changed
    end

    def new_record?
      @new_record
    end

    def set_permitted_sites(attributes)
      if authorization_level != "regular"
        @permitted_sites = []
        @sites = Site.none
      elsif attributes[:permitted_sites].present?
        @permitted_sites = attributes[:permitted_sites].select(&:present?).map(&:to_i).compact
        @sites = Site.where(id: permitted_sites)
      elsif @admin
        @permitted_sites = @admin.sites.pluck(:id)
        @sites = @admin.sites
      else
        @permitted_sites = []
        @sites = Site.none
      end
    end

    def set_admin_groups(attributes)
      @admin_group_ids = if authorization_level != "regular"
                           []
                         elsif attributes[:admin_group_ids].present?
                           attributes[:admin_group_ids].select(&:present?).map(&:to_i).compact
                         elsif @admin
                           @admin.admin_groups.pluck(:id)
                         else
                           []
                         end
      @admin_groups = AdminGroup.where(id: admin_group_ids)
    end

    def allowed_admin_groups
      permitted_sites_existing_groups = @admin.admin_groups.where(site: sites.where.not(id: site.id))
      site_groups = admin_groups.where(site: site)

      permitted_sites_existing_groups + site_groups
    end

    def save_admin
      @admin = admin.tap do |admin_attributes|
        admin_attributes.name = name
        admin_attributes.email = email
        admin_attributes.password = password if password
        admin_attributes.authorization_level = authorization_level if authorization_level.present?
        admin_attributes.creation_ip = creation_ip
      end

      # Check changes
      @email_changed = @admin.email_changed?

      if @admin.valid?
        ActiveRecord::Base.transaction do
          @admin.save unless persisted?
          # TODO: site permissions are being duplicated, add constraints or something
          # AR has no way to tell 2 records represent the same
          @admin.sites = []
          @admin.sites = sites # This is a has_many through association
          @admin.admin_groups = allowed_admin_groups
          @admin.save
        end

        @admin
      else
        promote_errors(@admin.errors)

        false
      end
    end

    def send_invitation?
      new_record?
    end

    def send_invitation
      admin.regenerate_invitation_token
      deliver_invitation_email
    end

    protected

    def deliver_invitation_email
      AdminMailer.invitation_instructions(admin).deliver_later
    end
  end
end
