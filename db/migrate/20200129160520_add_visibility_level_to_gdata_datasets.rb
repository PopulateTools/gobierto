# frozen_string_literal: true

class AddVisibilityLevelToGdataDatasets < ActiveRecord::Migration[5.2]
  def change
    add_column :gdata_datasets, :visibility_level, :integer, null: false, default: 0
  end
end
