# frozen_string_literal: true

class CreateGobiertoPeopleDepartment < ActiveRecord::Migration[5.2]

  def change
    create_table :gp_departments do |t|
      t.belongs_to :site, null: false
      t.string :name, null: false
    end
  end

end
