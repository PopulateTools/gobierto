# frozen_string_literal: true

class GenerateDepartmentsSlugsAndAddConstraints < ActiveRecord::Migration[5.2]
  def up
    ::GobiertoPeople::Department.all.each(&:save!)
    change_column :gp_departments, :slug, :string, null: false
    add_index :gp_departments, [:site_id, :slug], unique: true
  end

  def down
    remove_index :gp_departments, [:site_id, :slug]
    change_column :gp_departments, :slug, :string, null: true
    ::GobiertoPeople::Department.update_all(slug: nil)
  end
end
