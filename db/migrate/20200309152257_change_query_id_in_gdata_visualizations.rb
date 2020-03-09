# frozen_string_literal: true

class ChangeQueryIdInGdataVisualizations < ActiveRecord::Migration[5.2]
  def change
    add_reference :gdata_visualizations, :dataset, index: true

    ::GobiertoData::Visualization.all.each do |visualization|
      visualization.update_attribute(:dataset_id, visualization.query.dataset_id)
    end
  end
end
