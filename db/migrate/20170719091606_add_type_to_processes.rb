# frozen_string_literal: true

class AddTypeToProcesses < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_processes, :process_type, :integer, default: GobiertoParticipation::Process.process_types[:group_process], null: false
  end
end
