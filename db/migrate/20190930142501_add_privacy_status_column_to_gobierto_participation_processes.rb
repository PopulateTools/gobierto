# frozen_string_literal: true

class AddPrivacyStatusColumnToGobiertoParticipationProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :gpart_processes, :privacy_status, :integer, null: false, default: 0
  end
end
