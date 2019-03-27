# frozen_string_literal: true

class AddActiveFlagToProcessStages < ActiveRecord::Migration[5.1]

  def change
    add_column :gpart_process_stages, :active, :boolean, null: false, default: false
  end

end
