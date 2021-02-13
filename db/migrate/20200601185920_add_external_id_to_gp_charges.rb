# frozen_string_literal: true

class AddExternalIdToGpCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :gp_charges, :external_id, :string
  end
end
