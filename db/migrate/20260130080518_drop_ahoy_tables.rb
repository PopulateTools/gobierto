# frozen_string_literal: true

# ABOUTME: Migration to drop ahoy_visits and ahoy_events tables.
# ABOUTME: Part of ahoy gem removal.

class DropAhoyTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :ahoy_events
    drop_table :ahoy_visits
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
