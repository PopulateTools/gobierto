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

ActiveRecord::Schema.define(version: 20170530144711) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", force: :cascade do |t|
    t.string   "action",         null: false
    t.string   "subject_type"
    t.integer  "subject_id"
    t.string   "author_type"
    t.integer  "author_id"
    t.string   "recipient_type"
    t.integer  "recipient_id"
    t.inet     "subject_ip",     null: false
    t.boolean  "admin_activity", null: false
    t.integer  "site_id"
    t.datetime "created_at",     null: false
    t.index ["admin_activity"], name: "index_activities_on_admin_activity", using: :btree
    t.index ["author_type", "author_id"], name: "index_activities_on_author_type_and_author_id", using: :btree
    t.index ["recipient_type", "recipient_id"], name: "index_activities_on_recipient_type_and_recipient_id", using: :btree
    t.index ["site_id"], name: "index_activities_on_site_id", using: :btree
    t.index ["subject_id", "subject_type"], name: "index_activities_on_subject_id_and_subject_type", using: :btree
    t.index ["subject_type", "subject_id"], name: "index_activities_on_subject_type_and_subject_id", using: :btree
  end

  create_table "admin_admin_sites", force: :cascade do |t|
    t.integer "admin_id"
    t.integer "site_id"
    t.index ["admin_id", "site_id"], name: "index_admin_admin_sites_on_admin_id_and_site_id", using: :btree
    t.index ["admin_id"], name: "index_admin_admin_sites_on_admin_id", using: :btree
    t.index ["site_id"], name: "index_admin_admin_sites_on_site_id", using: :btree
  end

  create_table "admin_admins", force: :cascade do |t|
    t.string   "email",                                null: false
    t.string   "name",                 default: "",    null: false
    t.string   "password_digest",      default: "",    null: false
    t.string   "confirmation_token"
    t.string   "reset_password_token"
    t.integer  "authorization_level",  default: 0,     null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.datetime "last_sign_in_at"
    t.inet     "last_sign_in_ip"
    t.inet     "creation_ip"
    t.boolean  "god",                  default: false, null: false
    t.string   "invitation_token"
    t.datetime "invitation_sent_at"
    t.string "preview_token",                          null: false
    t.index ["confirmation_token"], name: "index_admin_admins_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_admin_admins_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_admin_admins_on_invitation_token", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_admins_on_reset_password_token", unique: true, using: :btree
    t.index ["preview_token"], name: "index_admin_admins_on_preview_token", unique: true
  end

  create_table "admin_census_imports", force: :cascade do |t|
    t.integer  "admin_id"
    t.integer  "site_id"
    t.integer  "imported_records", default: 0,     null: false
    t.boolean  "completed",        default: false, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["admin_id"], name: "index_admin_census_imports_on_admin_id", using: :btree
    t.index ["site_id"], name: "index_admin_census_imports_on_site_id", using: :btree
  end

  create_table "admin_permissions", force: :cascade do |t|
    t.integer "admin_id"
    t.string  "namespace",     default: "", null: false
    t.string  "resource_name", default: "", null: false
    t.string  "action_name",   default: "", null: false
    t.index ["admin_id", "namespace", "resource_name", "action_name"], name: "index_admin_permissions_on_admin_id_and_fields", using: :btree
    t.index ["admin_id"], name: "index_admin_permissions_on_admin_id", using: :btree
  end

  create_table "census_items", force: :cascade do |t|
    t.integer "site_id"
    t.string  "document_number_digest", default: "",    null: false
    t.string  "date_of_birth",          default: "",    null: false
    t.integer "import_reference"
    t.boolean "verified",               default: false, null: false
    t.index ["site_id", "document_number_digest", "date_of_birth", "verified"], name: "index_census_items_on_site_id_and_doc_number_and_birth_verified", using: :btree
    t.index ["site_id", "document_number_digest", "date_of_birth"], name: "index_census_items_on_site_id_and_doc_number_and_date_of_birth", using: :btree
    t.index ["site_id", "import_reference"], name: "index_census_items_on_site_id_and_import_reference", using: :btree
    t.index ["site_id"], name: "index_census_items_on_site_id", using: :btree
  end

  create_table "content_block_fields", force: :cascade do |t|
    t.integer "content_block_id"
    t.integer "field_type",       default: 0,  null: false
    t.string  "name",             default: "", null: false
    t.text    "label"
    t.integer "position",         default: 0,  null: false
    t.index ["content_block_id"], name: "index_content_block_fields_on_content_block_id", using: :btree
  end

  create_table "content_block_records", force: :cascade do |t|
    t.integer  "content_block_id"
    t.string   "content_context_type"
    t.integer  "content_context_id"
    t.jsonb    "payload"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["content_block_id"], name: "index_content_block_records_on_content_block_id", using: :btree
    t.index ["content_context_type", "content_context_id"], name: "index_content_block_records_on_content_context", using: :btree
    t.index ["payload"], name: "index_content_block_records_on_payload", using: :gin
  end

  create_table "content_blocks", force: :cascade do |t|
    t.integer "site_id"
    t.string  "content_model_name", default: "", null: false
    t.hstore  "title"
    t.string  "internal_id",        default: ""
    t.index ["content_model_name"], name: "index_content_blocks_on_content_model_name", using: :btree
    t.index ["site_id"], name: "index_content_blocks_on_site_id", using: :btree
  end

  create_table "custom_user_field_records", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "custom_user_field_id"
    t.jsonb    "payload"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["custom_user_field_id"], name: "index_custom_user_field_records_on_custom_user_field_id", using: :btree
    t.index ["payload"], name: "index_custom_user_field_records_on_payload", using: :gin
    t.index ["user_id"], name: "index_custom_user_field_records_on_user_id", using: :btree
  end

  create_table "custom_user_fields", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "position",   default: 0,     null: false
    t.hstore   "title"
    t.boolean  "mandatory",  default: false
    t.integer  "field_type", default: 0,     null: false
    t.jsonb    "options"
    t.string   "name",       default: "",    null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["site_id", "name"], name: "index_custom_user_fields_on_site_id_and_name", unique: true, using: :btree
    t.index ["site_id"], name: "index_custom_user_fields_on_site_id", using: :btree
  end

  create_table "gbc_consultation_items", force: :cascade do |t|
    t.string   "title",                                       default: "",    null: false
    t.text     "description"
    t.string   "budget_line_id",                              default: "",    null: false
    t.decimal  "budget_line_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.integer  "position",                                    default: 0,     null: false
    t.integer  "consultation_id"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.string   "budget_line_name",                            default: "",    null: false
    t.boolean  "block_reduction",                             default: false
    t.index ["consultation_id"], name: "index_gbc_consultation_items_on_consultation_id", using: :btree
  end

  create_table "gbc_consultation_responses", force: :cascade do |t|
    t.integer  "consultation_id"
    t.text     "consultation_items"
    t.decimal  "budget_amount",          precision: 12, scale: 2, default: "0.0", null: false
    t.integer  "visibility_level",                                default: 0,     null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "sharing_token"
    t.string   "document_number_digest"
    t.jsonb    "user_information"
    t.index ["consultation_id", "document_number_digest"], name: "index_gbc_consultation_responses_on_document_number_digest", unique: true, using: :btree
    t.index ["consultation_id"], name: "index_gbc_consultation_responses_on_consultation_id", using: :btree
    t.index ["sharing_token"], name: "index_gbc_consultation_responses_on_sharing_token", unique: true, using: :btree
    t.index ["user_information"], name: "index_gbc_consultation_responses_on_user_information", using: :gin
  end

  create_table "gbc_consultations", force: :cascade do |t|
    t.string   "title",                                            default: "",    null: false
    t.text     "description",                                      default: "",    null: false
    t.date     "opens_on"
    t.date     "closes_on"
    t.integer  "visibility_level",                                 default: 0,     null: false
    t.decimal  "budget_amount",           precision: 12, scale: 2, default: "0.0", null: false
    t.integer  "admin_id"
    t.integer  "site_id"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.boolean  "show_figures",                                     default: true
    t.boolean  "force_responses_balance",                          default: false
    t.index ["admin_id"], name: "index_gbc_consultations_on_admin_id", using: :btree
    t.index ["site_id"], name: "index_gbc_consultations_on_site_id", using: :btree
  end

  create_table "gcms_pages", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "visibility_level",   default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.jsonb    "title_translations"
    t.jsonb    "body_translations"
    t.jsonb    "slug_translations"
    t.index ["body_translations"], name: "index_gcms_pages_on_body_translations", using: :gin
    t.index ["site_id"], name: "index_gcms_pages_on_site_id", using: :btree
    t.index ["slug_translations"], name: "index_gcms_pages_on_slug_translations", using: :gin
    t.index ["title_translations"], name: "index_gcms_pages_on_title_translations", using: :gin
  end

  create_table "gobierto_module_settings", force: :cascade do |t|
    t.integer  "site_id"
    t.string   "module_name"
    t.jsonb    "settings"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["site_id", "module_name"], name: "index_gobierto_module_settings_on_site_id_and_module_name", unique: true, using: :btree
    t.index ["site_id"], name: "index_gobierto_module_settings_on_site_id", using: :btree
  end

  create_table "gp_people", force: :cascade do |t|
    t.integer  "site_id"
    t.integer  "admin_id"
    t.string   "name",                  default: "",     null: false
    t.string   "bio_url"
    t.integer  "visibility_level",      default: 0,      null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "avatar_url"
    t.integer  "events_count",          default: 0,      null: false
    t.integer  "statements_count",      default: 0,      null: false
    t.integer  "posts_count",           default: 0,      null: false
    t.integer  "political_group_id"
    t.integer  "category",              default: 0,      null: false
    t.integer  "party"
    t.integer  "position",              default: 999999, null: false
    t.string   "email"
    t.jsonb    "charge_translations"
    t.jsonb    "bio_translations"
    t.string   "slug",                                   null: false
    t.string   "google_calendar_token"
    t.index ["admin_id"], name: "index_gp_people_on_admin_id", using: :btree
    t.index ["bio_translations"], name: "index_gp_people_on_bio_translations", using: :gin
    t.index ["category", "party"], name: "index_gp_people_on_category_and_party", using: :btree
    t.index ["category"], name: "index_gp_people_on_category", using: :btree
    t.index ["charge_translations"], name: "index_gp_people_on_charge_translations", using: :gin
    t.index ["google_calendar_token"], name: "index_gp_people_on_google_calendar_token", unique: true, using: :btree
    t.index ["party"], name: "index_gp_people_on_party", using: :btree
    t.index ["political_group_id"], name: "index_gp_people_on_political_group_id", using: :btree
    t.index ["site_id"], name: "index_gp_people_on_site_id", using: :btree
    t.index ["slug"], name: "index_gp_people_on_slug", unique: true, using: :btree
  end

  create_table "gp_person_calendar_configurations", force: :cascade do |t|
    t.integer "person_id",              null: false
    t.jsonb   "data",      default: {}, null: false
    t.index ["person_id"], name: "index_gp_person_calendar_configurations_on_person_id", unique: true, using: :btree
  end

  create_table "gp_person_event_attendees", force: :cascade do |t|
    t.string   "name"
    t.string   "charge"
    t.integer  "person_id"
    t.integer  "person_event_id", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["person_event_id"], name: "index_gp_person_event_attendees_on_person_event_id", using: :btree
    t.index ["person_id"], name: "index_gp_person_event_attendees_on_person_id", using: :btree
  end

  create_table "gp_person_event_locations", force: :cascade do |t|
    t.string   "name",                                     default: "", null: false
    t.string   "address"
    t.decimal  "lat",             precision: 10, scale: 6
    t.decimal  "lng",             precision: 10, scale: 6
    t.integer  "person_event_id",                                       null: false
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.index ["person_event_id"], name: "index_gp_person_event_locations_on_person_event_id", using: :btree
  end

  create_table "gp_person_events", force: :cascade do |t|
    t.datetime "starts_at",                            null: false
    t.datetime "ends_at",                              null: false
    t.string   "attachment_url"
    t.integer  "state",                    default: 0, null: false
    t.integer  "person_id",                            null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "external_id"
    t.jsonb    "title_translations"
    t.jsonb    "description_translations"
    t.integer  "site_id",                              null: false
    t.string   "slug",                                 null: false
    t.index ["description_translations"], name: "index_gp_person_events_on_description_translations", using: :gin
    t.index ["person_id", "external_id"], name: "index_gp_person_events_on_person_id_and_external_id", unique: true, using: :btree
    t.index ["person_id"], name: "index_gp_person_events_on_person_id", using: :btree
    t.index ["slug"], name: "index_gp_person_events_on_slug", unique: true, using: :btree
    t.index ["title_translations"], name: "index_gp_person_events_on_title_translations", using: :gin
  end

  create_table "gp_person_posts", force: :cascade do |t|
    t.string   "title",            default: "", null: false
    t.text     "body"
    t.string   "tags",                                       array: true
    t.integer  "visibility_level", default: 0,  null: false
    t.integer  "person_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "site_id",                       null: false
    t.string   "slug",                          null: false
    t.index ["person_id"], name: "index_gp_person_posts_on_person_id", using: :btree
    t.index ["slug"], name: "index_gp_person_posts_on_slug", unique: true, using: :btree
    t.index ["tags"], name: "index_gp_person_posts_on_tags", using: :gin
  end

  create_table "gp_person_statements", force: :cascade do |t|
    t.date     "published_on",                   null: false
    t.integer  "person_id"
    t.integer  "visibility_level",   default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "attachment_url"
    t.integer  "attachment_size"
    t.jsonb    "title_translations"
    t.integer  "site_id",                        null: false
    t.string   "slug",                           null: false
    t.index ["person_id"], name: "index_gp_person_statements_on_person_id", using: :btree
    t.index ["slug"], name: "index_gp_person_statements_on_slug", unique: true, using: :btree
    t.index ["title_translations"], name: "index_gp_person_statements_on_title_translations", using: :gin
  end

  create_table "gp_political_groups", force: :cascade do |t|
    t.string   "name",       default: "", null: false
    t.integer  "site_id"
    t.integer  "admin_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "position",   default: 0,  null: false
    t.string   "slug",                    null: false
    t.index ["admin_id"], name: "index_gp_political_groups_on_admin_id", using: :btree
    t.index ["position"], name: "index_gp_political_groups_on_position", using: :btree
    t.index ["site_id"], name: "index_gp_political_groups_on_site_id", using: :btree
    t.index ["slug"], name: "index_gp_political_groups_on_slug", unique: true, using: :btree
  end

  create_table "gp_settings", force: :cascade do |t|
    t.integer  "site_id"
    t.string   "key",        default: "", null: false
    t.string   "value",      default: "", null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["site_id"], name: "index_gp_settings_on_site_id", using: :btree
  end

  create_table "sites", force: :cascade do |t|
    t.string   "external_id"
    t.string   "domain"
    t.text     "configuration_data"
    t.string   "location_name"
    t.string   "location_type"
    t.string   "institution_url"
    t.string   "institution_type"
    t.string   "institution_email"
    t.string   "institution_address"
    t.string   "institution_document_number"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "visibility_level",            default: 0, null: false
    t.inet     "creation_ip"
    t.integer  "municipality_id"
    t.jsonb    "name_translations"
    t.jsonb    "title_translations"
    t.index ["name_translations"], name: "index_sites_on_name_translations", using: :gin
    t.index ["title_translations"], name: "index_sites_on_title_translations", using: :gin
  end

  create_table "translations", force: :cascade do |t|
    t.string   "locale"
    t.string   "key"
    t.text     "value"
    t.text     "interpolations"
    t.boolean  "is_proc",        default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["key"], name: "index_translations_on_key", using: :btree
    t.index ["locale"], name: "index_translations_on_locale", using: :btree
  end

  create_table "user_notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.string   "action"
    t.string   "subject_type"
    t.integer  "subject_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_sent",      default: false, null: false
    t.boolean  "is_seen",      default: false, null: false
    t.index ["is_seen"], name: "index_user_notifications_on_is_seen", using: :btree
    t.index ["is_sent"], name: "index_user_notifications_on_is_sent", using: :btree
    t.index ["site_id"], name: "index_user_notifications_on_site_id", using: :btree
    t.index ["subject_type", "subject_id", "site_id", "user_id"], name: "index_user_notifications_on_subject_and_site_id_and_user_id", using: :btree
    t.index ["subject_type", "subject_id", "site_id"], name: "index_user_notifications_on_subject_and_site_id", using: :btree
    t.index ["user_id", "site_id"], name: "index_user_notifications_on_user_id_and_site_id", using: :btree
    t.index ["user_id"], name: "index_user_notifications_on_user_id", using: :btree
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.string   "subscribable_type"
    t.integer  "subscribable_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["site_id"], name: "index_user_subscriptions_on_site_id", using: :btree
    t.index ["subscribable_type", "site_id"], name: "index_user_subscriptions_on_subscribable_type_and_site_id", using: :btree
    t.index ["subscribable_type", "subscribable_id", "site_id", "user_id"], name: "index_user_subscriptions_on_type_and_id_and_user_id", unique: true, using: :btree
    t.index ["subscribable_type", "subscribable_id", "site_id"], name: "index_user_subscriptions_on_type_and_id", using: :btree
    t.index ["user_id", "site_id"], name: "index_user_subscriptions_on_user_id_and_site_id", using: :btree
    t.index ["user_id"], name: "index_user_subscriptions_on_user_id", using: :btree
  end

  create_table "user_verifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.integer  "verification_type", default: 0,     null: false
    t.string   "verification_data"
    t.inet     "creation_ip"
    t.integer  "version",           default: 0,     null: false
    t.boolean  "verified",          default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["site_id"], name: "index_user_verifications_on_site_id", using: :btree
    t.index ["user_id"], name: "index_user_verifications_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                                  null: false
    t.string   "name"
    t.string   "bio"
    t.string   "password_digest"
    t.string   "confirmation_token"
    t.string   "reset_password_token"
    t.inet     "creation_ip"
    t.datetime "last_sign_in_at"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "source_site_id"
    t.boolean  "census_verified",        default: false, null: false
    t.integer  "gender"
    t.integer  "notification_frequency", default: 0,     null: false
    t.date     "date_of_birth"
    t.string   "referrer_url"
    t.string   "referrer_entity"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["notification_frequency"], name: "index_users_on_notification_frequency", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["source_site_id"], name: "index_users_on_source_site_id", using: :btree
  end

  add_foreign_key "gp_person_events", "sites"
  add_foreign_key "gp_person_posts", "sites"
  add_foreign_key "gp_person_statements", "sites"
end
