# frozen_string_literal: true

class AddAttributesToGobiertoParticipationProcessStages < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_process_stages, :menu_translations, :jsonb
    add_column :gpart_process_stages, :cta_description_translations, :jsonb
    add_column :gpart_process_stages, :visibility_level, :integer, null: false, default: 0
  end
end
