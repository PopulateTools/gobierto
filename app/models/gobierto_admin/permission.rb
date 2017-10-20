require_dependency "gobierto_admin"

module GobiertoAdmin
  class Permission < ApplicationRecord
    belongs_to :admin

    scope :for_modules, -> { where(namespace: 'site_module') }
    scope :for_people, -> { where(namespace: 'gobierto_people', resource_name: 'person') }

    validates :admin_id, presence: true
    validates :namespace, presence: true
    validates :resource_name, presence: true
    validates :action_name, presence: true
    validates :namespace, uniqueness: { scope: [:admin_id, :resource_name, :resource_id, :action_name] }

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
