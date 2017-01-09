class CreateGobiertoPeoplePersonEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :gp_person_events do |t|
      t.string :title, null: false, default: ""
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :attachment_url
      t.integer :state, null: false, default: 0
      t.references :person

      t.timestamps
    end
  end
end
