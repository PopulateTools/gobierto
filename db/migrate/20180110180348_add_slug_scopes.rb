# frozen_string_literal: true

class AddSlugScopes < ActiveRecord::Migration[5.1]
  def change
    add_column :scopes, :slug, :string, null: false, default: ""
  end
end
