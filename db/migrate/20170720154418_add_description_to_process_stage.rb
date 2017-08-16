# frozen_string_literal: true

class AddDescriptionToProcessStage < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_process_stages, :description_translations, :jsonb
  end
end
