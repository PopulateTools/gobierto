module GobiertoAdmin
  class AdminForm
    include ActiveModel::Model

    attr_accessor(
      :id,
      :name,
      :email,
      :password,
      :password_confirmation,
      :authorization_level,
      :creation_ip,
      :last_sign_in_at,
      :last_sign_in_ip
    )

    attr_reader :permissions, :permitted_sites, :permitted_modules, :permitted_people, :sites

    delegate :persisted?, to: :admin

    validates :name, :email, presence: true
    validates :email, format: { with: Admin::EMAIL_ADDRESS_REGEXP }
    validates :password, presence: { if: :new_record? }, confirmation: true

    def permitted_modules_names
      permitted_modules.map{ |m| m.underscore }
    end

    def initialize(attributes = {})
      parsed_attributes = attributes.to_h.with_indifferent_access

      super(parsed_attributes.except(
        :permitted_sites,
        :permitted_modules,
        :permitted_people,
        :all_people_permitted
      ))

      set_permitted_sites(parsed_attributes)
      set_permitted_modules(parsed_attributes)
      set_permitted_people(parsed_attributes)
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
      if attributes[:authorization_level] != 'regular'
        @permitted_sites = []
        @sites = []
      elsif attributes[:permitted_sites].present?
        @permitted_sites = attributes[:permitted_sites].select{ |id| id.present? }.map{|id| id.to_i }.compact
        @sites = Site.where(id: permitted_sites)
      elsif @admin
        @permitted_sites = @admin.sites.pluck(:id)
        @sites = @admin.sites
      else
        @permitted_sites = []
        @sites = []
      end
    end

    def set_permitted_modules(attributes)
      if attributes[:authorization_level] != 'regular'
        @permitted_modules = []
      elsif attributes[:permitted_modules].present?
        @permitted_modules = attributes[:permitted_modules].select{ |m| m.present? }.compact
      elsif @admin
        @permitted_modules = @admin.modules_permissions.pluck(:resource_name)
      else
        @permitted_modules = []
      end
    end

    def set_permitted_people(attributes)
      if attributes[:authorization_level] != 'regular'
        @permitted_people = []
      elsif attributes[:all_people_permitted] && attributes[:all_people_permitted] == 'on'
        @permitted_people = ::GobiertoPeople::Person.where(site: sites).active.pluck(:id)
      elsif attributes[:permitted_people].present?
        @permitted_people = attributes[:permitted_people].select{ |m| m.present? }.map{|id| id.to_i }.compact
      elsif @admin
        @permitted_people = @admin.people_permissions.pluck(:resource_id)
      else
        @permitted_people = []
      end
    end

    def build_permissions
      @permissions = admin.permissions
      build_modules_permissions
      build_people_permissions
      @permissions
    end

    def build_modules_permissions
      existing_module_permissions = admin.permissions.where(namespace: 'site_module', action_name: 'manage')
      revoked_module_permissions_ids = existing_module_permissions.where.not(resource_name: permitted_modules_names).pluck(:id)

      @permissions.each do |p|
        p.mark_for_destruction if revoked_module_permissions_ids.include?(p.id)
      end

      if permitted_modules_names.exclude?('gobierto_people')
        mark_people_permissions_for_destruction
      end

      permitted_modules_names.map do |module_name|
        unless existing_module_permissions.exists?(resource_name: module_name)
          @permissions << build_permission_for_module(module_name)
        end
      end
    end

    def build_people_permissions
      existing_people_permissions    = admin.permissions.where(namespace: 'gobierto_people', resource_name: 'person', action_name: 'manage')
      revoked_people_permissions_ids = existing_people_permissions.where.not(resource_id: permitted_people).pluck(:id)

      @permissions.each do |p|
        p.mark_for_destruction if revoked_people_permissions_ids.include?(p.id)
      end

      permitted_people.map do |person_id|
        person = ::GobiertoPeople::Person.find_by(id: person_id)
        if meets_requirements_for_managing_person?(person) && !existing_people_permissions.exists?(resource_id: person.id)
          @permissions << build_permission_for_person(person)
        end
      end

      # if site permissions where revoked, revoke site people permissions
      revoked_people_permissions_ids = []
      @permissions.each do |permission|
        if permission.resource_name == 'person'
          person_site = ::GobiertoPeople::Person.find_by(id: permission.resource_id).site
          if !permitted_sites.include?(person_site.id)
            revoked_people_permissions_ids << permission.id
          end
        end
      end

      @permissions.each do |p|
        p.mark_for_destruction if revoked_people_permissions_ids.include?(p.id)
      end
    end

    def meets_requirements_for_managing_person?(person)
      person && person.site && permitted_sites.include?(person.site.id) && permitted_modules_names.include?('gobierto_people')
    end

    def mark_people_permissions_for_destruction
      people_permissions_ids = admin.permissions.where(
        namespace: 'gobierto_people',
        resource_name: 'person',
        action_name: 'manage'
      ).pluck(:id)
      @permissions.each do |p|
        p.mark_for_destruction if people_permissions_ids.include?(p.id)
      end
    end

    def build_permission_for_module(module_name)
      ::GobiertoAdmin::Permission.new(
        admin: admin,
        namespace: 'site_module',
        resource_name: module_name,
        action_name: 'manage'
      )
    end

    def build_permission_for_person(person)
      ::GobiertoAdmin::Permission.new(
        admin: admin,
        namespace: 'gobierto_people',
        resource_name: 'person',
        resource_id: person.id,
        action_name: 'manage'
      )
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
          @admin.permissions = build_permissions
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

    def promote_errors(errors_hash)
      errors_hash.each do |attribute, message|
        errors.add(attribute, message)
      end
    end

    def deliver_invitation_email
      AdminMailer.invitation_instructions(admin).deliver_later
    end
  end
end
