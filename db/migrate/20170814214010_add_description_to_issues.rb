# frozen_string_literal: true

class AddDescriptionToIssues < ActiveRecord::Migration[5.1]
  def change
    add_column :issues, :description_translations, :jsonb
  end
end
