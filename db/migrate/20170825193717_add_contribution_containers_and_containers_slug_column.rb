# frozen_string_literal: true

class AddContributionContainersAndContainersSlugColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_contribution_containers, :slug, :string, null: false, default: ""
    add_column :gpart_contributions, :slug, :string, null: false, default: ""
  end
end
