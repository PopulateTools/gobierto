# frozen_string_literal: true

class AddStageTypeToProcessStage < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_process_stages, :stage_type, :integer, default: 0, null: false
  end
end
