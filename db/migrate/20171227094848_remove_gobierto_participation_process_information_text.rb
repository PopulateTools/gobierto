# frozen_string_literal: true

class RemoveGobiertoParticipationProcessInformationText < ActiveRecord::Migration[5.1]
  def up
    remove_column :gpart_processes, :information_text_translations
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
