# frozen_string_literal: true

class AddIndexToSitesDomain < ActiveRecord::Migration[5.1]
  def change
    add_index :sites, :domain, unique: true
  end
end
