class CreateGobiertoCalendarsFilteringRules < ActiveRecord::Migration[5.1]
  def change
    create_table :gc_filtering_rules do |t|
      t.references :calendar_configuration
      t.integer :field, null: false
      t.integer :condition, null: false
      t.string :value, null: false
      t.integer :action, null: false
      t.timestamps
    end
  end
end
