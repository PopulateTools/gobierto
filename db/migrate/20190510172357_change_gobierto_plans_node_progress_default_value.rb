# frozen_string_literal: true

class ChangeGobiertoPlansNodeProgressDefaultValue < ActiveRecord::Migration[5.2]
  def change
    change_column_default :gplan_nodes, :progress, from: nil, to: 0.0
  end
end
