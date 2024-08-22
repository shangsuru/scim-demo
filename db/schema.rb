# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_08_07_131602) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: :cascade do |t|
    t.text "scim_uid"
    t.text "display_name"
    t.bigint "parent_id"
    t.index ["parent_id"], name: "index_groups_on_parent_id"
  end

  create_table "groups_users", id: false, force: :cascade do |t|
    t.bigint "group_id", null: false
    t.uuid "user_id", null: false
    t.index ["group_id"], name: "index_groups_users_on_group_id"
    t.index ["user_id"], name: "index_groups_users_on_user_id"
  end

  create_table "users", primary_key: "primary_key", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "scim_uid"
    t.text "username"
    t.text "password"
    t.text "first_name"
    t.text "last_name"
    t.text "work_email_address"
    t.text "home_email_address"
    t.text "work_phone_number"
    t.text "organization"
    t.text "department"
    t.text "manager"
  end

  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users", primary_key: "primary_key"
end
