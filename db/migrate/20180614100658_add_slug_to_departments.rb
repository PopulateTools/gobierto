# frozen_string_literal: true

class AddSlugToDepartments < ActiveRecord::Migration[5.2]
  def change
    add_column :gp_departments, :slug, :string
  end
end
