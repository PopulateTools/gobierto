# frozen_string_literal: true

class AddSqlToGdataVisualizations < ActiveRecord::Migration[5.2]
  def change
    add_column :gdata_visualizations, :sql, :string
  end
end
