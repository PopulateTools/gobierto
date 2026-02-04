# ABOUTME: Migration to add performance indexes to gc_events table.
# ABOUTME: Addresses slow queries in person events listings.

class AddPerformanceIndexesToGcEvents < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :gc_events, [:site_id, :state, :starts_at],
              order: { starts_at: :desc },
              where: "archived_at IS NULL",
              name: "index_gc_events_on_site_state_starts_not_archived",
              algorithm: :concurrently

    add_index :gc_events, :slug,
              using: :gin,
              opclass: :gin_trgm_ops,
              name: "index_gc_events_on_slug_trgm",
              algorithm: :concurrently

    add_index :gc_events, :starts_at,
              name: "index_gc_events_on_starts_at",
              algorithm: :concurrently
  end
end
