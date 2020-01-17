# frozen_string_literal: true

class AddTimestampsToDataTables < ActiveRecord::Migration[5.2]
  def change
    add_column :gdata_datasets, :data_updated_at, :datetime

    add_timestamps :gdata_queries, default: Time.zone.now
    change_column_default :gdata_queries, :created_at, from: Time.zone.now, to: nil
    change_column_default :gdata_queries, :updated_at, from: Time.zone.now, to: nil

    add_timestamps :gdata_visualizations, default: Time.zone.now
    change_column_default :gdata_visualizations, :created_at, from: Time.zone.now, to: nil
    change_column_default :gdata_visualizations, :updated_at, from: Time.zone.now, to: nil
  end
end
