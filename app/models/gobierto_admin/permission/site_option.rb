# frozen_string_literal: true

module GobiertoAdmin
  class Permission::SiteOption < Permission

    RESOURCE_NAMES = %i(customize vocabularies templates).freeze

    def self.label_text(resource_name)
      I18n.t("activerecord.attributes.gobierto_admin/permission/site_option.resource_names.#{resource_name}")
    end

  end
end
