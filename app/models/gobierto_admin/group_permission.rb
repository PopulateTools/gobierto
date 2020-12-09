# frozen_string_literal: true

module GobiertoAdmin
  class GroupPermission < ApplicationRecord
    belongs_to :admin_group
    belongs_to :resource, polymorphic: true, optional: true

    scope :global, -> { where(namespace: "global", resource_type: "global") }
    scope :for_modules, -> { where(namespace: "site_module") }
    scope :for_people, -> { where(namespace: "gobierto_people", resource_type: "GobiertoPeople::Person") }
    scope :for_site_people, ->(site_ids) { for_people.joins("JOIN gp_people ON gp_people.id = admin_group_permissions.resource_id").where(gp_people: { site_id: site_ids }) }
    scope :for_site_options, -> { where(namespace: "site_options") }
    scope :for_class_module, -> { for_modules.where(resource_type: model.name.demodulize.underscore) }
    scope :on_site, ->(site) { joins(:admin_group).where(admin_admin_groups: { site_id: site.id }) }

    validates :admin_group_id, presence: true
    validates :namespace, presence: true
    validates :resource_type, presence: true
    validates :action_name, presence: true
    validates :namespace, uniqueness: { scope: [:admin_group_id, :resource_type, :resource_id, :action_name] }

    def for_person?
      (namespace == "gobierto_people") && (resource_type == "GobiertoPeople::Person")
    end

    def person_record_permission?
      for_person? && resource_id.present? && (action_name == "manage")
    end

    def self.by_namespace(namespace)
      where(namespace: namespace)
    end

    def self.by_resource(resource_type)
      where(resource_type: resource_type)
    end

    def self.resource_types
      pluck(:resource_type)
    end

    def self.action_names
      pluck(:action_name)
    end

    def self.can?(action_name)
      exists?(action_name: action_name)
    end

    def self.grant(action_name)
      create(action_name: action_name)
    end

    def self.deny(action_name)
      find_by(action_name: action_name).try(:destroy)
    end
  end
end
