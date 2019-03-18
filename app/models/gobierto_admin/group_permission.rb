# frozen_string_literal: true

require_dependency "gobierto_admin"

module GobiertoAdmin
  class GroupPermission < ApplicationRecord
    belongs_to :admin_group

    scope :global, -> { where(namespace: "global", resource_name: "global") }
    scope :for_modules, -> { where(namespace: "site_module") }
    scope :for_people, -> { where(namespace: "gobierto_people", resource_name: "person") }
    scope :for_site_people, ->(site_ids) { for_people.joins("JOIN gp_people ON gp_people.id = admin_group_permissions.resource_id").where(gp_people: { site_id: site_ids }) }
    scope :for_site_options, -> { where(namespace: "site_options") }
    scope :for_class_module, -> { for_modules.where(resource_name: model.name.demodulize.underscore) }

    validates :admin_group_id, presence: true
    validates :namespace, presence: true
    validates :resource_name, presence: true
    validates :action_name, presence: true
    validates :namespace, uniqueness: { scope: [:admin_group_id, :resource_name, :resource_id, :action_name] }

    def for_person?
      (namespace == "gobierto_people") && (resource_name == "person")
    end

    def person_record_permission?
      for_person? && resource_id.present? && (action_name == "manage")
    end

    def self.by_namespace(namespace)
      where(namespace: namespace)
    end

    def self.by_resource(resource_name)
      where(resource_name: resource_name)
    end

    def self.resource_names
      pluck(:resource_name)
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
