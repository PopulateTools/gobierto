# frozen_string_literal: true

module GobiertoAdmin
  class Permission::SiteOption < GroupPermission

    RESOURCE_TYPES = [:customize, :vocabularies, :templates, :custom_fields, :calendars, :documents].freeze

    def self.label_text(resource_type)
      I18n.t("activerecord.attributes.gobierto_admin/permission/site_option.resource_types.#{resource_type}")
    end

  end
end
