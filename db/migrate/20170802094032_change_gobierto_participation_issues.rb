# frozen_string_literal: true

class ChangeGobiertoParticipationIssues < ActiveRecord::Migration[5.1]
  def change
    rename_table :gpart_issues, :issues
  end
end
