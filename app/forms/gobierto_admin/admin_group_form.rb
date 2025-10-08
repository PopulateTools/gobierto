# frozen_string_literal: true

module GobiertoAdmin
  class AdminGroupForm < BaseForm
    PERMISSION_TYPES = {
      site_options: { scope: :site_options_permissions, attribute: :resource_type },
      modules_actions: { scope: :modules_permissions, attribute: :resource_type, action_names: { gobierto_plans: :plans_action_names } },
      people: { scope: :people_permissions, attribute: :resource_id, parent_type: :modules_actions, parent: :gobierto_people, allow_all: true }
    }.freeze

    attr_accessor(
      :id,
      :name,
      :site_id,
      :parsed_attributes,
      :permissions_configuration
    )

    attr_reader :permissions

    attr_writer(
      :resource_type,
      :resource_id
    )

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
      set_all_permissions
    end

    def save
      @new_record = admin_group.new_record?

      return false unless valid?

      save_admin_group
    end

    def admin_group
      @admin_group ||= AdminGroup.find_by(id: id).presence || build_admin_group
    end

    def action_names(permission_type, resource_type = nil)
      return unless PERMISSION_TYPES.has_key? permission_type

      names = PERMISSION_TYPES.dig(permission_type, :action_names, resource_type.to_sym) || [:manage]
      names.is_a?(Symbol) ? send(names) : names
    end

    def resource_type
      @resource_type ||= admin_group.resource_type
    end

    def resource_id
      @resource_id ||= admin_group.resource_id
    end

    private

    def plans_action_names
      AdminActionsManager.for("gobierto_plans", site).action_names
    end

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

    def action_names_from_attributes(options)
      if options[:parent] && parsed_attributes[options[:parent_type]].is_a?(Hash) && parsed_attributes[options[:parent_type]][options[:parent]].present?
        parsed_attributes[options[:parent_type]][options[:parent]].select(&:present?)
      else
        [:manage]
      end
    end

    def action_names_from_configuration(options)
      return [:manage] unless options[:parent]

      permissions_configuration[options[:parent_type]][options[:parent]] || []
    end

    def set_permissions
      @permissions_configuration ||= {}

      PERMISSION_TYPES.each do |permission_type, options|
        action_names = action_names_from_attributes(options)
        @permissions_configuration[permission_type] = if parsed_attributes[permission_type].present?
                                                        if options[:action_names]
                                                          parsed_attributes[permission_type].transform_values { |actions| actions.select(&:present?) }
                                                        else
                                                          parsed_attributes[permission_type].select(&:present?).inject({}) do |configuration, option|
                                                            configuration.update(
                                                              option => action_names
                                                            )
                                                          end
                                                        end
                                                      else
                                                        {}
                                                      end.deep_stringify_keys
        define_singleton_method(permission_type) do
          @permissions_configuration[permission_type]
        end
      end
    end

    def set_all_permissions
      @permissions_configuration ||= {}

      PERMISSION_TYPES.each do |permission_type, options|
        action_names = action_names_from_attributes(options)

        next unless options[:allow_all]

        all_action_names = action_names.map { |name| "#{name}_all" }

        option_symbol = :"all_#{permission_type}"
        @permissions_configuration[option_symbol] = if parsed_attributes[option_symbol].present?
                                                      ["1", true].include?(parsed_attributes[option_symbol])
                                                    elsif admin_group.persisted?
                                                      admin_group.send(options[:scope]).exists?(action_name: all_action_names)
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
        existing_permissions = admin_group.send(options[:scope])
        action_names = action_names_from_configuration(options)

        if options[:allow_all]
          all_action_names = action_names.map { |name| "#{name}_all" }
          existing_permissions = existing_permissions.where.not(action_name: all_action_names)
        end

        revoked_permissions_ids.concat(revoked_permissions(existing_permissions, permission_type, options).pluck(:id))

        add_permissions(existing_permissions, permission_type, options)

        next unless options[:allow_all]

        action_names.each do |action_name|
          existing_permission_ids = admin_group.send(options[:scope]).where(action_name: "#{action_name}_all").pluck(:id)

          if revoke_all_permission?(permission_type, options)
            revoked_permissions_ids.concat(existing_permission_ids)
          elsif permissions_configuration[:"all_#{permission_type}"] && existing_permission_ids.blank?
            @permissions << admin_group.send(options[:scope]).new(action_name: "#{action_name}_all")
          end
        end
      end

      @permissions.each do |permission|
        permission.mark_for_destruction if revoked_permissions_ids.include?(permission.id)
      end

      @permissions
    end

    def add_permissions(existing_permissions, permission_type, options)
      return if parent_disabled?(options)

      permissions_configuration[permission_type].each do |option_name, action_names|
        action_names.each do |action_name|
          next if existing_permissions.exists?(options[:attribute] => option_name, action_name: action_name)

          @permissions << admin_group.send(options[:scope]).new(options[:attribute] => option_name, action_name: action_name)
        end
      end
    end

    def revoked_permissions(existing_permissions, permission_type, options)
      return existing_permissions if parent_disabled?(options)

      revoked_ids = []

      existing_permissions.group(options[:attribute]).distinct.pluck(options[:attribute]).each do |option_name|
        action_names = permissions_configuration[permission_type][option_name.to_s] || []
        revoked_ids.concat existing_permissions.where.not(action_name: action_names).where(options[:attribute] => option_name).pluck(:id)
      end

      existing_permissions.where(id: revoked_ids)
    end

    def parent_disabled?(options)
      options[:parent].present? && !permissions_configuration_values(options[:parent_type]).include?(options[:parent].to_s)
    end

    def permissions_configuration_values(permission_type)
      configuration = permissions_configuration[permission_type]
      if configuration.is_a? Hash
        configuration.select { |_, action_names| action_names.present? }
      else
        permissions_configuration[permission_type].select(&:present?)
      end
    end

    def revoke_all_permission?(permission_type, options)
      permissions_configuration[permission_type].any? ||
        !permissions_configuration[:"all_#{permission_type}"] ||
        !permissions_configuration[options[:parent_type]].reject { |_, actions| actions.blank? }.include?(options[:parent].to_s)
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
