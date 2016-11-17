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

ActiveRecord::Schema.define(version: 20161117070200) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "admin_permissions", force: :cascade do |t|
    t.integer "admin_id"
    t.string  "namespace",     default: "", null: false
    t.string  "resource_name", default: "", null: false
    t.string  "action_name",   default: "", null: false
    t.index ["admin_id", "namespace", "resource_name", "action_name"], name: "index_admin_permissions_on_admin_id_and_fields", using: :btree
    t.index ["admin_id"], name: "index_admin_permissions_on_admin_id", using: :btree
  end

  create_table "admin_sites", force: :cascade do |t|
    t.integer "admin_id"
    t.integer "site_id"
    t.index ["admin_id", "site_id"], name: "index_admin_sites_on_admin_id_and_site_id", using: :btree
    t.index ["admin_id"], name: "index_admin_sites_on_admin_id", using: :btree
    t.index ["site_id"], name: "index_admin_sites_on_site_id", using: :btree
  end

  create_table "admins", force: :cascade do |t|
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
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_admins_on_email", unique: true, using: :btree
    t.index ["invitation_token"], name: "index_admins_on_invitation_token", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  end

  create_table "sites", force: :cascade do |t|
    t.string   "external_id"
    t.string   "name"
    t.string   "domain"
    t.text     "configuration_data"
    t.string   "location_name"
    t.string   "location_type"
    t.string   "institution_url"
    t.string   "institution_type"
    t.string   "institution_email"
    t.string   "institution_address"
    t.string   "institution_document_number"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "title",                       default: "", null: false
    t.integer  "visibility_level",            default: 0,  null: false
    t.inet     "creation_ip"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                             null: false
    t.string   "name",                              null: false
    t.string   "bio"
    t.string   "password_digest",      default: "", null: false
    t.string   "confirmation_token"
    t.string   "reset_password_token"
    t.inet     "creation_ip"
    t.datetime "last_sign_in_at"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "source_site_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["source_site_id"], name: "index_users_on_source_site_id", using: :btree
  end

end
