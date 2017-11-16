# frozen_string_literal: true

class AddUserLevelToPollsAndContributionContainers < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_polls, :visibility_user_level, :integer, null: false, default: 0
    add_column :gpart_contribution_containers, :visibility_user_level, :integer, null: false, default: 0
  end
end
