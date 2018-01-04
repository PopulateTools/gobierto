# frozen_string_literal: true

class CreateProcessStagePages < ActiveRecord::Migration[5.1]
  def change
    create_table :gpart_process_stage_pages do |t|
      t.belongs_to :process_stage, null: false
      t.belongs_to :page, null: false

      t.timestamps
    end
  end
end
