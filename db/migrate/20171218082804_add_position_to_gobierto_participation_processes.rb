# frozen_string_literal: true

class AddPositionToGobiertoParticipationProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_process_stages, :position, :integer, default: 999999, null: false
    add_index :gpart_process_stages, :position
  end
end
