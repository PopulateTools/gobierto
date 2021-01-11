# frozen_string_literal: true

class AddSizeColumnToGdataDatasetsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :gdata_datasets, :size, :jsonb
  end
end
