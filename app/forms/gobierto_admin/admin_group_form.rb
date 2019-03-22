# frozen_string_literal: true

module GobiertoAdmin
  class AdminGroupForm < BaseForm
    PERMISSION_TYPES = {
      site_options: { scope: :site_options_permissions, attribute: :resource_name },
      modules: { scope: :modules_permissions, attribute: :resource_name, attribute_parse_method: :underscore },
      people: { scope: :people_permissions, attribute: :resource_id, parent_type: :modules, parent: :gobierto_people, allow_all: true }
    }.freeze

    attr_accessor(
      :id,
      :name,
      :site_id,
      :parsed_attributes,
      :permissions_configuration
    )

    attr_reader :permissions

    delegate :persisted?, to: :admin_group

    validates :name, :site, presence: true

    def initialize(attributes = {})
      @parsed_attributes = attributes.to_h.with_indifferent_access
      PERMISSION_TYPES.each do |permission_type, options|
        next unless options[:attribute_parse_method] && @parsed_attributes[permission_type].present?

        @parsed_attributes[permission_type] = @parsed_attributes[permission_type].map { |attribute| attribute.send(options[:attribute_parse_method]) }
      end

      super(parsed_attributes.except(*permissions_keys))
      set_permissions
    end

    def save
      @new_record = admin_group.new_record?

      return false unless valid?

      save_admin_group
    end

    def admin_group
      @admin_group ||= AdminGroup.find_by(id: id).presence || build_admin_group
    end

    private

    def site
      Site.find_by(id: site_id)
    end

    def permissions_keys
      PERMISSION_TYPES.keys + PERMISSION_TYPES.select { |_, options| options[:allow_all] }.keys.map { |permission_type| :"all_#{permission_type}" }
    end

    def build_admin_group
      AdminGroup.new(site_id: site_id)
    end

    def new_record?
      @new_record
    end

    def set_permissions
      @permissions_configuration ||= {}

      PERMISSION_TYPES.each do |permission_type, options|
        @permissions_configuration[permission_type] = if parsed_attributes[permission_type].present?
                                                        parsed_attributes[permission_type].select(&:present?).compact
                                                      elsif @admin_group
                                                        @admin_group.send(options[:scope]).pluck(options[:attribute])
                                                      else
                                                        []
                                                      end

        define_singleton_method(permission_type) do
          @permissions_configuration[permission_type]
        end

        next unless options[:allow_all]

        option_symbol = :"all_#{permission_type}"
        @permissions_configuration[option_symbol] = if parsed_attributes[option_symbol].present?
                                                      ["1", true].include?(parsed_attributes[option_symbol])
                                                    elsif admin_group.persisted?
                                                      admin_group.send(options[:scope]).exists?(action_name: "manage_all")
                                                    else
                                                      false
                                                    end
        define_singleton_method(option_symbol) do
          @permissions_configuration[option_symbol]
        end
      end
    end

    def build_permissions
      @permissions = admin_group.permissions
      revoked_permissions_ids = []
      PERMISSION_TYPES.each do |permission_type, options|
        existing_manage_permissions = admin_group.send(options[:scope]).where(action_name: "manage")

        revoked_permissions_ids.concat(revoked_permissions(existing_manage_permissions, permission_type, options).pluck(:id))

        permissions_configuration[permission_type].map do |option_name|
          unless parent_disabled?(options) || existing_manage_permissions.exists?(options[:attribute] => option_name)
            @permissions << admin_group.send(options[:scope]).new(action_name: "manage", options[:attribute] => option_name)
          end
        end

        next unless options[:allow_all] && !parent_disabled?(options)

        existing_permission_ids = admin_group.send(options[:scope]).where(action_name: "manage_all").pluck(:id)

        if revoke_manage_all_permission?(permission_type, options)
          revoked_permissions_ids.concat(existing_permission_ids)
        elsif permissions_configuration[:"all_#{permission_type}"] && existing_permission_ids.blank?
          @permissions << admin_group.send(options[:scope]).new(action_name: "manage_all")
        end
      end

      @permissions.each do |permission|
        permission.mark_for_destruction if revoked_permissions_ids.include?(permission.id)
      end

      @permissions
    end

    def revoked_permissions(existing_permissions, permission_type, options)
      return existing_permissions if parent_disabled?(options)

      existing_permissions.where.not(options[:attribute] => permissions_configuration[permission_type])
    end

    def parent_disabled?(options)
      options[:parent].present? && !permissions_configuration[options[:parent_type]].include?(options[:parent].to_s)
    end

    def revoke_manage_all_permission?(permission_type, options)
      permissions_configuration[permission_type].any? ||
        !permissions_configuration[:"all_#{permission_type}"] ||
        !permissions_configuration[:modules].include?(options[:parent].to_s)
    end

    def mark_people_permissions_for_destruction
      people_permissions_ids = admin_group.permissions.where(
        namespace: "gobierto_people",
        resource_name: "person",
        action_name: "manage"
      ).pluck(:id)
      @permissions.each do |p|
        p.mark_for_destruction if people_permissions_ids.include?(p.id)
      end
    end

    def save_admin_group
      @admin_group = admin_group.tap do |attributes|
        attributes.name = name
      end

      if @admin_group.valid?
        ActiveRecord::Base.transaction do
          @admin_group.save unless persisted?
          @admin_group.permissions = build_permissions
          @admin_group.save
        end

        @admin_group
      else
        promote_errors(@admin_group.errors)

        false
      end
    end
  end
end
