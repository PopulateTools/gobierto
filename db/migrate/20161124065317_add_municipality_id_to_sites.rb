# frozen_string_literal: true

class AddMunicipalityIdToSites < ActiveRecord::Migration[5.0]
  def change
    add_column :sites, :municipality_id, :integer
  end
end
