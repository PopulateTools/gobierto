class CreateGobiertoPeoplePersonStatements < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_person_statements do |t|
      t.string :title, null: false, default: ""
      t.date :published_on
      t.references :person
      t.integer :visibility_level, null: false, default: 0

      t.timestamps
    end
  end
end
