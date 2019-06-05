# frozen_string_literal: true

class AddPublishedVersionToGplanNodes < ActiveRecord::Migration[5.2]
  def change
    add_column :gplan_nodes, :published_version, :integer
  end
end
