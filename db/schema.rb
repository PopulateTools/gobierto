# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171218152031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", id: :serial, force: :cascade do |t|
    t.string "action", null: false
    t.string "subject_type"
    t.integer "subject_id"
    t.string "author_type"
    t.integer "author_id"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.inet "subject_ip", null: false
    t.boolean "admin_activity", null: false
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.index ["admin_activity"], name: "index_activities_on_admin_activity"
    t.index ["author_type", "author_id"], name: "index_activities_on_author_type_and_author_id"
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id"
    t.index ["site_id"], name: "index_activities_on_site_id"
    t.index ["subject_id", "subject_type"], name: "index_activities_on_subject_id_and_subject_type"
    t.index ["subject_type", "subject_id"], name: "index_activities_on_subject_type_and_subject_id"
  end

  create_table "admin_admin_sites", id: :serial, force: :cascade do |t|
    t.integer "admin_id"
    t.integer "site_id"
    t.index ["admin_id", "site_id"], name: "index_admin_admin_sites_on_admin_id_and_site_id"
    t.index ["admin_id"], name: "index_admin_admin_sites_on_admin_id"
    t.index ["site_id", "admin_id"], name: "index_admin_admin_sites_on_site_id_and_admin_id", unique: true
    t.index ["site_id"], name: "index_admin_admin_sites_on_site_id"
  end

  create_table "admin_admins", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "name", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.string "confirmation_token"
    t.string "reset_password_token"
    t.integer "authorization_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.inet "creation_ip"
    t.boolean "god", default: false, null: false
    t.string "invitation_token"
    t.datetime "invitation_sent_at"
    t.string "preview_token", null: false
    t.index ["confirmation_token"], name: "index_admin_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admin_admins_on_email", unique: true
    t.index ["invitation_token"], name: "index_admin_admins_on_invitation_token", unique: true
    t.index ["preview_token"], name: "index_admin_admins_on_preview_token", unique: true
    t.index ["reset_password_token"], name: "index_admin_admins_on_reset_password_token", unique: true
  end

  create_table "admin_census_imports", id: :serial, force: :cascade do |t|
    t.integer "admin_id"
    t.integer "site_id"
    t.integer "imported_records", default: 0, null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_census_imports_on_admin_id"
    t.index ["site_id"], name: "index_admin_census_imports_on_site_id"
  end

  create_table "admin_permissions", id: :serial, force: :cascade do |t|
    t.integer "admin_id"
    t.string "namespace", default: "", null: false
    t.string "resource_name", default: "", null: false
    t.string "action_name", default: "", null: false
    t.bigint "resource_id"
    t.index ["admin_id", "namespace", "resource_name", "action_name"], name: "index_admin_permissions_on_admin_id_and_fields"
    t.index ["admin_id"], name: "index_admin_permissions_on_admin_id"
  end

  create_table "census_items", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "document_number_digest", default: "", null: false
    t.string "date_of_birth", default: "", null: false
    t.integer "import_reference"
    t.boolean "verified", default: false, null: false
    t.index ["site_id", "document_number_digest", "date_of_birth", "verified"], name: "index_census_items_on_site_id_and_doc_number_and_birth_verified"
    t.index ["site_id", "document_number_digest", "date_of_birth"], name: "index_census_items_on_site_id_and_doc_number_and_date_of_birth"
    t.index ["site_id", "import_reference"], name: "index_census_items_on_site_id_and_import_reference"
    t.index ["site_id"], name: "index_census_items_on_site_id"
  end

  create_table "collection_items", force: :cascade do |t|
    t.string "item_type"
    t.bigint "item_id"
    t.string "container_type"
    t.bigint "container_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "collection_id"
    t.index ["collection_id"], name: "index_collection_items_on_collection_id"
    t.index ["container_type", "container_id"], name: "index_collection_items_on_container_type_and_container_id"
    t.index ["item_type", "item_id"], name: "index_collection_items_on_item_type_and_item_id"
  end

  create_table "collections", force: :cascade do |t|
    t.bigint "site_id"
    t.jsonb "title_translations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "container_type"
    t.bigint "container_id"
    t.string "item_type"
    t.string "slug", default: "", null: false
    t.index ["container_id", "container_type", "item_type"], name: "index_collections_on_container_and_item_type", unique: true
    t.index ["site_id", "slug"], name: "index_collections_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_collections_on_site_id"
  end

  create_table "content_block_fields", id: :serial, force: :cascade do |t|
    t.integer "content_block_id"
    t.integer "field_type", default: 0, null: false
    t.string "name", default: "", null: false
    t.text "label"
    t.integer "position", default: 0, null: false
    t.index ["content_block_id"], name: "index_content_block_fields_on_content_block_id"
  end

  create_table "content_block_records", id: :serial, force: :cascade do |t|
    t.integer "content_block_id"
    t.string "content_context_type"
    t.integer "content_context_id"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachment_url"
    t.index ["content_block_id"], name: "index_content_block_records_on_content_block_id"
    t.index ["content_context_type", "content_context_id"], name: "index_content_block_records_on_content_context"
    t.index ["payload"], name: "index_content_block_records_on_payload", using: :gin
  end

  create_table "content_blocks", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "content_model_name", default: "", null: false
    t.hstore "title"
    t.string "internal_id", default: ""
    t.index ["content_model_name"], name: "index_content_blocks_on_content_model_name"
    t.index ["site_id"], name: "index_content_blocks_on_site_id"
  end

  create_table "custom_user_field_records", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "custom_user_field_id"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_user_field_id"], name: "index_custom_user_field_records_on_custom_user_field_id"
    t.index ["payload"], name: "index_custom_user_field_records_on_payload", using: :gin
    t.index ["user_id"], name: "index_custom_user_field_records_on_user_id"
  end

  create_table "custom_user_fields", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "position", default: 0, null: false
    t.hstore "title"
    t.boolean "mandatory", default: false
    t.integer "field_type", default: 0, null: false
    t.jsonb "options"
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "name"], name: "index_custom_user_fields_on_site_id_and_name", unique: true
    t.index ["site_id"], name: "index_custom_user_fields_on_site_id"
  end

  create_table "data_migrations", id: false, force: :cascade do |t|
    t.string "version", null: false
    t.index ["version"], name: "unique_data_migrations", unique: true
  end

  create_table "ga_attachings", force: :cascade do |t|
    t.integer "site_id", null: false
    t.integer "attachment_id", null: false
    t.integer "attachable_id", null: false
    t.string "attachable_type", null: false
    t.index ["site_id", "attachment_id", "attachable_id", "attachable_type"], name: "record_unique_index", unique: true
  end

  create_table "ga_attachments", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "name"
    t.text "description"
    t.string "file_name", null: false
    t.string "file_digest", null: false
    t.string "url", null: false
    t.integer "file_size", null: false
    t.integer "current_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", default: "", null: false
    t.integer "collection_id"
    t.index ["site_id", "slug"], name: "index_ga_attachments_on_site_id_and_slug", unique: true
  end

  create_table "gb_budget_line_feedbacks", force: :cascade do |t|
    t.bigint "site_id"
    t.integer "year"
    t.string "budget_line_id"
    t.integer "answer1"
    t.integer "answer2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_gb_budget_line_feedbacks_on_site_id"
  end

  create_table "gb_categories", force: :cascade do |t|
    t.integer "site_id", null: false
    t.string "area_name", null: false
    t.string "kind", null: false
    t.string "code", null: false
    t.jsonb "custom_name_translations"
    t.jsonb "custom_description_translations"
    t.index ["site_id", "area_name", "kind", "code"], name: "gb_categories_record_unique_index", unique: true
  end

  create_table "gbc_consultation_items", id: :serial, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "description"
    t.string "budget_line_id", default: "", null: false
    t.decimal "budget_line_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.integer "consultation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "budget_line_name", default: "", null: false
    t.boolean "block_reduction", default: false
    t.index ["consultation_id"], name: "index_gbc_consultation_items_on_consultation_id"
  end

  create_table "gbc_consultation_responses", id: :serial, force: :cascade do |t|
    t.integer "consultation_id"
    t.text "consultation_items"
    t.decimal "budget_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "visibility_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sharing_token"
    t.string "document_number_digest"
    t.jsonb "user_information"
    t.index ["consultation_id", "document_number_digest"], name: "index_gbc_consultation_responses_on_document_number_digest", unique: true
    t.index ["consultation_id"], name: "index_gbc_consultation_responses_on_consultation_id"
    t.index ["sharing_token"], name: "index_gbc_consultation_responses_on_sharing_token", unique: true
    t.index ["user_information"], name: "index_gbc_consultation_responses_on_user_information", using: :gin
  end

  create_table "gbc_consultations", id: :serial, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "description", default: "", null: false
    t.date "opens_on"
    t.date "closes_on"
    t.integer "visibility_level", default: 0, null: false
    t.decimal "budget_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "admin_id"
    t.integer "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_figures", default: true
    t.boolean "force_responses_balance", default: false
    t.index ["admin_id"], name: "index_gbc_consultations_on_admin_id"
    t.index ["site_id"], name: "index_gbc_consultations_on_site_id"
  end

  create_table "gc_calendar_configurations", id: :serial, force: :cascade do |t|
    t.jsonb "data", default: {}, null: false
    t.bigint "collection_id", null: false
    t.string "integration_name", null: false
    t.index ["collection_id"], name: "index_gc_calendar_configurations_on_collection_id", unique: true
  end

  create_table "gc_event_attendees", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "charge"
    t.integer "person_id"
    t.integer "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_gc_event_attendees_on_event_id"
    t.index ["person_id"], name: "index_gc_event_attendees_on_person_id"
  end

  create_table "gc_event_locations", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "address"
    t.decimal "lat", precision: 10, scale: 6
    t.decimal "lng", precision: 10, scale: 6
    t.integer "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_gc_event_locations_on_event_id"
  end

  create_table "gc_events", id: :serial, force: :cascade do |t|
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "state", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.jsonb "title_translations"
    t.jsonb "description_translations"
    t.integer "site_id", null: false
    t.string "slug", null: false
    t.integer "collection_id"
    t.index ["description_translations"], name: "index_gc_events_on_description_translations", using: :gin
    t.index ["site_id", "slug"], name: "index_gc_events_on_site_id_and_slug", unique: true
    t.index ["title_translations"], name: "index_gc_events_on_title_translations", using: :gin
  end

  create_table "gcms_pages", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "visibility_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "title_translations"
    t.jsonb "body_translations"
    t.string "slug", default: "", null: false
    t.integer "collection_id"
    t.jsonb "body_source_translations"
    t.index ["body_source_translations"], name: "index_gcms_pages_on_body_source_translations", using: :gin
    t.index ["body_translations"], name: "index_gcms_pages_on_body_translations", using: :gin
    t.index ["site_id", "slug"], name: "index_gcms_pages_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_gcms_pages_on_site_id"
    t.index ["title_translations"], name: "index_gcms_pages_on_title_translations", using: :gin
  end

  create_table "gcms_section_items", force: :cascade do |t|
    t.string "item_type"
    t.string "item_id"
    t.integer "position", default: 0, null: false
    t.integer "parent_id", null: false
    t.bigint "section_id"
    t.integer "level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_gcms_section_items_on_item_type_and_item_id"
    t.index ["section_id"], name: "index_gcms_section_items_on_section_id"
  end

  create_table "gcms_sections", force: :cascade do |t|
    t.jsonb "title_translations"
    t.string "slug", default: "", null: false
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "slug"], name: "index_gcms_sections_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_gcms_sections_on_site_id"
  end

  create_table "gcore_site_templates", force: :cascade do |t|
    t.text "markup"
    t.bigint "template_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_gcore_site_templates_on_site_id"
    t.index ["template_id"], name: "index_gcore_site_templates_on_template_id"
  end

  create_table "gcore_templates", force: :cascade do |t|
    t.string "template_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gobierto_module_settings", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "module_name"
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id", "module_name"], name: "index_gobierto_module_settings_on_site_id_and_module_name", unique: true
    t.index ["site_id"], name: "index_gobierto_module_settings_on_site_id"
  end

  create_table "gp_people", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.integer "admin_id"
    t.string "name", default: "", null: false
    t.string "bio_url"
    t.integer "visibility_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_url"
    t.integer "statements_count", default: 0, null: false
    t.integer "posts_count", default: 0, null: false
    t.integer "political_group_id"
    t.integer "category", default: 0, null: false
    t.integer "party"
    t.integer "position", default: 999999, null: false
    t.string "email"
    t.jsonb "charge_translations"
    t.jsonb "bio_translations"
    t.string "slug", null: false
    t.string "google_calendar_token"
    t.index ["admin_id"], name: "index_gp_people_on_admin_id"
    t.index ["bio_translations"], name: "index_gp_people_on_bio_translations", using: :gin
    t.index ["category", "party"], name: "index_gp_people_on_category_and_party"
    t.index ["category"], name: "index_gp_people_on_category"
    t.index ["charge_translations"], name: "index_gp_people_on_charge_translations", using: :gin
    t.index ["google_calendar_token"], name: "index_gp_people_on_google_calendar_token", unique: true
    t.index ["party"], name: "index_gp_people_on_party"
    t.index ["political_group_id"], name: "index_gp_people_on_political_group_id"
    t.index ["site_id", "slug"], name: "index_gp_people_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_gp_people_on_site_id"
  end

  create_table "gp_person_posts", id: :serial, force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "body"
    t.string "tags", array: true
    t.integer "visibility_level", default: 0, null: false
    t.integer "person_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "site_id", null: false
    t.string "slug", null: false
    t.index ["person_id"], name: "index_gp_person_posts_on_person_id"
    t.index ["site_id", "slug"], name: "index_gp_person_posts_on_site_id_and_slug", unique: true
    t.index ["tags"], name: "index_gp_person_posts_on_tags", using: :gin
  end

  create_table "gp_person_statements", id: :serial, force: :cascade do |t|
    t.date "published_on", null: false
    t.integer "person_id"
    t.integer "visibility_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachment_url"
    t.integer "attachment_size"
    t.jsonb "title_translations"
    t.integer "site_id", null: false
    t.string "slug", null: false
    t.index ["person_id"], name: "index_gp_person_statements_on_person_id"
    t.index ["site_id", "slug"], name: "index_gp_person_statements_on_site_id_and_slug", unique: true
    t.index ["title_translations"], name: "index_gp_person_statements_on_title_translations", using: :gin
  end

  create_table "gp_political_groups", id: :serial, force: :cascade do |t|
    t.string "name", default: "", null: false
    t.integer "site_id"
    t.integer "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0, null: false
    t.string "slug", null: false
    t.index ["admin_id"], name: "index_gp_political_groups_on_admin_id"
    t.index ["position"], name: "index_gp_political_groups_on_position"
    t.index ["site_id"], name: "index_gp_political_groups_on_site_id"
    t.index ["slug"], name: "index_gp_political_groups_on_slug", unique: true
  end

  create_table "gp_settings", id: :serial, force: :cascade do |t|
    t.integer "site_id"
    t.string "key", default: "", null: false
    t.string "value", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_gp_settings_on_site_id"
  end

  create_table "gpart_areas", force: :cascade do |t|
    t.bigint "site_id"
    t.jsonb "name_translations"
    t.jsonb "slug_translations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name_translations"], name: "index_gpart_areas_on_name_translations", using: :gin
    t.index ["site_id"], name: "index_gpart_areas_on_site_id"
    t.index ["slug_translations"], name: "index_gpart_areas_on_slug_translations", using: :gin
  end

  create_table "gpart_comments", force: :cascade do |t|
    t.text "body", default: "", null: false
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.bigint "user_id"
    t.bigint "site_id"
    t.integer "votes_count", default: 0
    t.integer "flags_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "comments_count", default: 0
    t.index ["commentable_type", "commentable_id"], name: "index_gpart_comments_on_commentable_type_and_commentable_id"
    t.index ["site_id"], name: "index_gpart_comments_on_site_id"
    t.index ["user_id"], name: "index_gpart_comments_on_user_id"
  end

  create_table "gpart_contribution_containers", force: :cascade do |t|
    t.jsonb "title_translations", default: "", null: false
    t.jsonb "description_translations", default: "", null: false
    t.date "starts"
    t.date "ends"
    t.integer "contribution_type", default: 0, null: false
    t.integer "visibility_level", default: 0, null: false
    t.bigint "process_id"
    t.bigint "admin_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", default: "", null: false
    t.integer "visibility_user_level", default: 0, null: false
    t.index ["admin_id"], name: "index_gpart_contribution_containers_on_admin_id"
    t.index ["process_id"], name: "index_gpart_contribution_containers_on_process_id"
    t.index ["site_id", "slug"], name: "index_gpart_contribution_containers_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_gpart_contribution_containers_on_site_id"
  end

  create_table "gpart_contributions", force: :cascade do |t|
    t.string "title", default: "", null: false
    t.text "description", default: "", null: false
    t.bigint "contribution_container_id"
    t.bigint "user_id"
    t.bigint "site_id"
    t.integer "votes_count", default: 0
    t.integer "flags_count", default: 0
    t.integer "comments_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", default: "", null: false
    t.index ["contribution_container_id"], name: "index_gpart_contributions_on_contribution_container_id"
    t.index ["description"], name: "index_gpart_contributions_on_description"
    t.index ["site_id", "slug"], name: "index_gpart_contributions_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_gpart_contributions_on_site_id"
    t.index ["title"], name: "index_gpart_contributions_on_title"
    t.index ["user_id"], name: "index_gpart_contributions_on_user_id"
  end

  create_table "gpart_flags", force: :cascade do |t|
    t.string "flaggable_type"
    t.bigint "flaggable_id"
    t.bigint "user_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flaggable_type", "flaggable_id"], name: "index_gpart_flags_on_flaggable_type_and_flaggable_id"
    t.index ["site_id"], name: "index_gpart_flags_on_site_id"
    t.index ["user_id"], name: "index_gpart_flags_on_user_id"
  end

  create_table "gpart_poll_answer_templates", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "text", null: false
    t.integer "order", default: 0, null: false
    t.index ["question_id"], name: "index_gpart_poll_answer_templates_on_question_id"
  end

  create_table "gpart_poll_answers", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.bigint "question_id", null: false
    t.integer "answer_template_id"
    t.text "text"
    t.bigint "user_id", null: false
    t.datetime "created_at"
    t.index ["poll_id"], name: "index_gpart_poll_answers_on_poll_id"
    t.index ["question_id", "user_id", "answer_template_id"], name: "unique_index_gpart_poll_answers_for_fixed_answer_questions", unique: true
    t.index ["question_id"], name: "index_gpart_poll_answers_on_question_id"
    t.index ["user_id", "answer_template_id"], name: "unique_index_gpart_poll_answers_for_open_answer_questions", unique: true
    t.index ["user_id"], name: "index_gpart_poll_answers_on_user_id"
  end

  create_table "gpart_poll_questions", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.jsonb "title_translations"
    t.integer "answer_type", default: 0, null: false
    t.integer "order", default: 0, null: false
    t.index ["poll_id"], name: "index_gpart_poll_questions_on_poll_id"
  end

  create_table "gpart_polls", force: :cascade do |t|
    t.bigint "process_id", null: false
    t.jsonb "title_translations"
    t.jsonb "description_translations"
    t.date "starts_at", null: false
    t.date "ends_at", null: false
    t.integer "visibility_level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility_user_level", default: 0, null: false
    t.index ["process_id"], name: "index_gpart_polls_on_process_id"
  end

  create_table "gpart_process_stages", force: :cascade do |t|
    t.bigint "process_id"
    t.jsonb "title_translations"
    t.date "starts"
    t.date "ends"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", null: false
    t.integer "stage_type", default: 0, null: false
    t.jsonb "description_translations"
    t.boolean "active", default: false, null: false
    t.jsonb "cta_text_translations"
    t.integer "position", default: 999999, null: false
    t.jsonb "menu_translations"
    t.jsonb "cta_description_translations"
    t.integer "visibility_level", default: 0, null: false
    t.index ["position"], name: "index_gpart_process_stages_on_position"
    t.index ["process_id", "slug"], name: "index_gpart_process_stages_on_process_id_and_slug", unique: true
    t.index ["process_id"], name: "index_gpart_process_stages_on_process_id"
    t.index ["title_translations"], name: "index_gpart_process_stages_on_title_translations", using: :gin
  end

  create_table "gpart_processes", force: :cascade do |t|
    t.bigint "site_id"
    t.string "slug", default: "", null: false
    t.integer "visibility_level", default: 0, null: false
    t.jsonb "title_translations"
    t.jsonb "body_translations"
    t.date "starts"
    t.date "ends"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "header_image_url"
    t.integer "process_type", default: 1, null: false
    t.integer "issue_id"
    t.jsonb "information_text_translations"
    t.bigint "scope_id"
    t.index ["body_translations"], name: "index_gpart_processes_on_body_translations", using: :gin
    t.index ["site_id", "slug"], name: "index_gpart_processes_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_gpart_processes_on_site_id"
    t.index ["title_translations"], name: "index_gpart_processes_on_title_translations", using: :gin
  end

  create_table "gpart_votes", force: :cascade do |t|
    t.string "votable_type"
    t.bigint "votable_id"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.bigint "user_id"
    t.bigint "site_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_gpart_votes_on_site_id"
    t.index ["user_id", "vote_scope"], name: "index_gpart_votes_on_user_id_and_vote_scope"
    t.index ["user_id"], name: "index_gpart_votes_on_user_id"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_gpart_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_type", "votable_id"], name: "index_gpart_votes_on_votable_type_and_votable_id"
  end

  create_table "issues", force: :cascade do |t|
    t.bigint "site_id"
    t.jsonb "name_translations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 0, null: false
    t.jsonb "description_translations"
    t.string "slug", default: "", null: false
    t.index ["name_translations"], name: "index_issues_on_name_translations", using: :gin
    t.index ["position"], name: "index_issues_on_position"
    t.index ["site_id", "slug"], name: "index_issues_on_site_id_and_slug", unique: true
    t.index ["site_id"], name: "index_issues_on_site_id"
  end

  create_table "scopes", force: :cascade do |t|
    t.bigint "site_id", null: false
    t.jsonb "name_translations", null: false
    t.jsonb "description_translations", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sites", id: :serial, force: :cascade do |t|
    t.string "external_id"
    t.string "domain"
    t.text "configuration_data"
    t.string "location_name"
    t.string "location_type"
    t.string "institution_url"
    t.string "institution_type"
    t.string "institution_email"
    t.string "institution_address"
    t.string "institution_document_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "visibility_level", default: 0, null: false
    t.inet "creation_ip"
    t.integer "municipality_id"
    t.jsonb "name_translations"
    t.jsonb "title_translations"
    t.index ["name_translations"], name: "index_sites_on_name_translations", using: :gin
    t.index ["title_translations"], name: "index_sites_on_title_translations", using: :gin
  end

  create_table "translations", id: :serial, force: :cascade do |t|
    t.string "locale"
    t.string "key"
    t.text "value"
    t.text "interpolations"
    t.boolean "is_proc", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_translations_on_key"
    t.index ["locale"], name: "index_translations_on_locale"
  end

  create_table "user_notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "site_id"
    t.string "action"
    t.string "subject_type"
    t.integer "subject_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_sent", default: false, null: false
    t.boolean "is_seen", default: false, null: false
    t.index ["is_seen"], name: "index_user_notifications_on_is_seen"
    t.index ["is_sent"], name: "index_user_notifications_on_is_sent"
    t.index ["site_id"], name: "index_user_notifications_on_site_id"
    t.index ["subject_type", "subject_id", "site_id", "user_id"], name: "index_user_notifications_on_subject_and_site_id_and_user_id"
    t.index ["subject_type", "subject_id", "site_id"], name: "index_user_notifications_on_subject_and_site_id"
    t.index ["user_id", "site_id"], name: "index_user_notifications_on_user_id_and_site_id"
    t.index ["user_id"], name: "index_user_notifications_on_user_id"
  end

  create_table "user_subscriptions", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "site_id"
    t.string "subscribable_type"
    t.integer "subscribable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_user_subscriptions_on_site_id"
    t.index ["subscribable_type", "site_id"], name: "index_user_subscriptions_on_subscribable_type_and_site_id"
    t.index ["subscribable_type", "subscribable_id", "site_id", "user_id"], name: "index_user_subscriptions_on_type_and_id_and_user_id", unique: true
    t.index ["subscribable_type", "subscribable_id", "site_id"], name: "index_user_subscriptions_on_type_and_id"
    t.index ["user_id", "site_id"], name: "index_user_subscriptions_on_user_id_and_site_id"
    t.index ["user_id"], name: "index_user_subscriptions_on_user_id"
  end

  create_table "user_verifications", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "site_id"
    t.integer "verification_type", default: 0, null: false
    t.string "verification_data"
    t.inet "creation_ip"
    t.integer "version", default: 0, null: false
    t.boolean "verified", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["site_id"], name: "index_user_verifications_on_site_id"
    t.index ["user_id"], name: "index_user_verifications_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "name"
    t.string "bio"
    t.string "password_digest"
    t.string "confirmation_token"
    t.string "reset_password_token"
    t.inet "creation_ip"
    t.datetime "last_sign_in_at"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_site_id"
    t.boolean "census_verified", default: false, null: false
    t.integer "gender"
    t.integer "notification_frequency", default: 0, null: false
    t.date "date_of_birth"
    t.string "referrer_url"
    t.string "referrer_entity"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["notification_frequency"], name: "index_users_on_notification_frequency"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["source_site_id"], name: "index_users_on_source_site_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "gc_events", "collections", on_delete: :cascade
  add_foreign_key "gc_events", "sites"
  add_foreign_key "gp_person_posts", "sites"
  add_foreign_key "gp_person_statements", "sites"
end
