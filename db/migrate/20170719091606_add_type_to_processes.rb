class AddTypeToProcesses < ActiveRecord::Migration[5.1]

  def change
    add_column :gpart_processes, :process_type, :string, default: GobiertoParticipation::Process::GROUP
    change_column :gpart_processes, :process_type, :string, null: false
  end

end
