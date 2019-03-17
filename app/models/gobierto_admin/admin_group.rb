# frozen_string_literal: true

require_dependency "gobierto_admin"

module GobiertoAdmin
  class AdminGroup < ApplicationRecord
    belongs_to :site
    has_and_belongs_to_many :admins, join_table: "admin_groups_admins"
    has_many :permissions, dependent: :destroy, autosave: true, class_name: "::GobiertoAdmin::GroupPermission"
    has_many :global_permissions, -> { global }, class_name: "::GobiertoAdmin::GroupPermission"
    has_many :modules_permissions, -> { for_modules }, class_name: "::GobiertoAdmin::GroupPermission"
    has_many :site_people_permissions, ->(group) { for_site_people([group.site_id]) }, class_name: "::GobiertoAdmin::GroupPermission"
    has_many :people_permissions, -> { for_people }, class_name: "::GobiertoAdmin::GroupPermission"
    has_many :site_options_permissions, -> { for_site_options }, class_name: "GobiertoAdmin::GroupPermission"

    validates :name, presence: true, uniqueness: { scope: :site_id }
  end
end
