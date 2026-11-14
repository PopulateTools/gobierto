# frozen_string_literal: true

# ABOUTME: Drops eight indexes with zero scans in production (gobiertodb, 2026-11-09).
# ABOUTME: Each one is unused by the code or covered by a wider index.

class RemoveUnusedIndexes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  INDEXES = {
    activities: {
      "index_activities_on_admin_activity" => "USING btree (admin_activity)"
    },
    collection_items: {
      "index_collection_items_on_container_type_and_container_id" => "USING btree (container_type, container_id)"
    },
    gc_events: {
      "index_gc_events_on_archived_at" => "USING btree (archived_at)",
      "index_gc_events_on_title_translations" => "USING gin (title_translations)"
    },
    pg_search_documents: {
      "pg_search_documents_on_content_idx" => "USING gin (content gin_trgm_ops)"
    },
    user_notifications: {
      "index_user_notifications_on_subject_and_site_id" => "USING btree (subject_type, subject_id, site_id)",
      "index_user_notifications_on_subject_and_site_id_and_user_id" => "USING btree (subject_type, subject_id, site_id, user_id)",
      "index_user_notifications_on_user_id" => "USING btree (user_id)"
    }
  }.freeze

  def up
    INDEXES.each do |table, indexes|
      indexes.each_key do |name|
        remove_index table, name: name, algorithm: :concurrently, if_exists: true
      end
    end
  end

  def down
    INDEXES.each do |table, indexes|
      indexes.each do |name, definition|
        execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS #{name} ON #{table} #{definition}"
      end
    end
  end
end
