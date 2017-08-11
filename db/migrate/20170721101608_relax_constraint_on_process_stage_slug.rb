# frozen_string_literal: true

class RelaxConstraintOnProcessStageSlug < ActiveRecord::Migration[5.1]
  def change
    remove_index :gpart_process_stages, name: "index_gpart_process_stages_on_slug"
    add_index :gpart_process_stages, [:process_id, :slug], unique: true
  end
end
