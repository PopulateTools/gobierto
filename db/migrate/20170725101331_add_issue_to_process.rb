class AddIssueToProcess < ActiveRecord::Migration[5.1]

  def change
    add_column :gpart_processes, :issue_id, :integer
  end

end
