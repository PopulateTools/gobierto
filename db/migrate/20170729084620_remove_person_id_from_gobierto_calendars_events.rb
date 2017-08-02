class RemovePersonIdFromGobiertoCalendarsEvents < ActiveRecord::Migration[5.1]
  def up
    add_column :gobierto_calendars_events, :collection_id, :integer

    GobiertoCalendars::Event.reset_column_information

    GobiertoPeople::Person.all.each do |p|
      p.send :create_events_collection
    end.size

    GobiertoCalendars::Event.all.each do |e|
      if p = GobiertoPeople::Person.find_by(id: e.person_id)
        collection = p.events_collection
        e.collection = collection
        e.save!

        collection.append(e)
      end
    end

    remove_column :gobierto_calendars_events, :person_id

    add_foreign_key :gobierto_calendars_events, :collections, on_delete: :cascade
  end

  def down
    remove_column :gobierto_calendars_events, :collection_id
    add_column :gobierto_calendars_events, :person_id, :integer, null: false
  end
end
