# frozen_string_literal: true

class AddExternalIdToGobiertoPlansNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :gplan_nodes, :external_id, :string
  end
end
