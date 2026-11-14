# frozen_string_literal: true

# ABOUTME: Indexes the lookup of a synchronized event by its external id.
# ABOUTME: gobierto_people:sync_agendas reads gc_events whole once per event without it.

class AddExternalIdIndexToGcEvents < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # GobiertoCalendars::EventForm#event runs
  # person.events.find_by(external_id:), that is
  # WHERE archived_at IS NULL AND collection_id = ? AND external_id = ?
  def change
    add_index :gc_events, [:collection_id, :external_id],
              where: "archived_at IS NULL",
              name: "index_gc_events_on_collection_id_and_external_id_not_archived",
              algorithm: :concurrently
  end
end
