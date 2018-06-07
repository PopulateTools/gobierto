# frozen_string_literal: true

class AddContraintsToInterestGroupSlug < ActiveRecord::Migration[5.2]

  def change
    change_column :gp_interest_groups, :slug, :string, null: false
    add_index :gp_interest_groups, [:site_id, :slug], unique: true
  end

end
