# frozen_string_literal: true

class AddResourceReferenceToAdminAdminGroups < ActiveRecord::Migration[5.2]
  def change
    add_reference :admin_admin_groups, :resource, polymorphic: true, allow_nil: true
  end
end
