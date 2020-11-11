class AddIndexActivitiesAction < ActiveRecord::Migration[5.2]
  def change
    add_index :activities, :action
    add_index :activities, :created_at
  end
end
