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
      :sites,
      :site_ids,
      :site_modules,
      :people,
      :creation_ip,
      :last_sign_in_at,
      :last_sign_in_ip
    )

    delegate :persisted?, to: :admin

    validates :name, :email, presence: true
    validates :email, format: { with: Admin::EMAIL_ADDRESS_REGEXP }
    validates :password, presence: { if: :new_record? }, confirmation: true
    validate :sites_presence_for_regulars
    validate :modules_presence_for_regulars

    def initialize(attributes = {})
      super(attributes)
      @site_modules = @site_modules.select{ |m| m.present? } if @site_modules.present?
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

    def site_modules
      return [] unless persisted?

      @site_modules ||= begin
        admin.permissions.by_namespace("site_module").resource_names.map(&:camelize)
      end
    end

    def sites
      @sites ||= Site.where(id: site_ids)
    end

    def site_ids
      @site_ids ||= admin.sites.map(&:id)
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

    def build_permissions
      site_modules.map do |site_module|
        next unless site_module.present?

        admin.send("#{site_module.underscore}_permissions").new(
          action_name: "manage"
        )
      end.compact
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

    def sites_presence_for_regulars
      if authorization_level == "regular" && sites && sites.empty?
        errors.add(:site_ids, I18n.t('errors.messages.array_too_short', count: 1))
      end
    end

    def modules_presence_for_regulars
      if authorization_level == "regular" && @site_modules && @site_modules.empty?
        errors.add(:site_modules, I18n.t('errors.messages.array_too_short', count: 1))
      end
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
