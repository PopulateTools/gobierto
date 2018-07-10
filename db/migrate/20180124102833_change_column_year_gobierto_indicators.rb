# frozen_string_literal: true

class ChangeColumnYearGobiertoIndicators < ActiveRecord::Migration[5.1]
  def change
    remove_column :gi_indicators, :year
    add_column :gi_indicators, :year, :integer
  end
end
