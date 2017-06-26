class AddCollectionReferenceToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :gobierto_calendars_events, :collection_id, :integer
    add_foreign_key :gobierto_calendars_events, :collections, on_delete: :cascade
  end
end
