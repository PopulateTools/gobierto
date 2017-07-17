class AddPositionToGobiertoParticipationIssues < ActiveRecord::Migration[5.1]
  def change
    add_column :gpart_issues, :position, :integer, default: 0, null: false
    add_index :gpart_issues, :position
  end
end
