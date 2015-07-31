# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150727180345) do

  create_table "authentications", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.string   "provider",      limit: 255
    t.string   "uid",           limit: 255
    t.string   "token",         limit: 255
    t.string   "token_secret",  limit: 255
    t.string   "refresh_token", limit: 255
    t.string   "api_key",       limit: 255
    t.datetime "expires_at"
    t.boolean  "expires",       limit: 1,   default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_venues", force: :cascade do |t|
    t.string   "geo_area_id",          limit: 255
    t.string   "remote_source",        limit: 64
    t.integer  "remote_id",            limit: 4
    t.string   "zip",                  limit: 10
    t.string   "phone",                limit: 24
    t.float    "lon",                  limit: 24
    t.float    "lat",                  limit: 24
    t.string   "name",                 limit: 255
    t.string   "state",                limit: 20
    t.string   "city",                 limit: 80
    t.string   "country",              limit: 2
    t.string   "address_1",            limit: 128
    t.string   "address_2",            limit: 128
    t.string   "address_3",            limit: 128
    t.string   "privacy",              limit: 24
    t.boolean  "is_private_residence", limit: 1
    t.string   "editable_by",          limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.integer  "user_id",                    limit: 4,                        null: false
    t.string   "type",                       limit: 255
    t.string   "title",                      limit: 255,                      null: false
    t.string   "slug",                       limit: 255,                      null: false
    t.string   "fee",                        limit: 124
    t.text     "description",                limit: 65535
    t.string   "display_privacy",            limit: 255,   default: "public"
    t.boolean  "display_listing",            limit: 1,     default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.float    "fee_amount",                 limit: 24
    t.string   "fee_currency",               limit: 16
    t.string   "fee_description",            limit: 24
    t.string   "fee_label",                  limit: 16
    t.boolean  "fee_required",               limit: 1
    t.integer  "event_venue_id",             limit: 4
    t.string   "remote_event_api_id",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone",                   limit: 124
    t.integer  "utc_offset",                 limit: 4
    t.boolean  "featured",                   limit: 1,     default: false
    t.boolean  "show_home_page",             limit: 1,     default: true
    t.integer  "priority",                   limit: 4,     default: 0
    t.string   "url_identifier",             limit: 24
    t.string   "rsvp_display_privacy",       limit: 24,    default: "public"
    t.string   "rsvp_count_display_privacy", limit: 24,    default: "public"
    t.boolean  "show_event_hosts",           limit: 1,     default: true
  end

  add_index "events", ["slug"], name: "slug_opt", unique: true, using: :btree
  add_index "events", ["start_date"], name: "start_date_opt", using: :btree
  add_index "events", ["user_id"], name: "user_opt", using: :btree

  create_table "excluded_remote_members", force: :cascade do |t|
    t.integer  "remote_member_id", limit: 4
    t.integer  "event_id",         limit: 4
    t.string   "exclude_type",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "excluded_remote_members", ["event_id"], name: "excluded_members_event_opt", using: :btree
  add_index "excluded_remote_members", ["remote_member_id"], name: "excluded_members_remotemem_opt", using: :btree

  create_table "geo_areas", force: :cascade do |t|
    t.integer  "geo_country_id", limit: 4
    t.string   "place_name",     limit: 200
    t.string   "state",          limit: 100
    t.string   "state_code",     limit: 20
    t.string   "zip",            limit: 10
    t.float    "latitude",       limit: 24
    t.float    "longitude",      limit: 24
    t.string   "source",         limit: 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_areas", ["geo_country_id", "state"], name: "geo_area_state_opt", using: :btree
  add_index "geo_areas", ["geo_country_id", "state_code"], name: "geo_area_state_code_opt", using: :btree
  add_index "geo_areas", ["geo_country_id", "zip"], name: "geo_area_zip_opt", using: :btree

  create_table "geo_cities", force: :cascade do |t|
    t.string   "city_name",       limit: 80
    t.string   "short_city_name", limit: 60
    t.integer  "geo_region_id",   limit: 4
    t.integer  "geo_country_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_cities", ["geo_country_id", "geo_region_id"], name: "geo_cities_region_opt", using: :btree

  create_table "geo_continents", force: :cascade do |t|
    t.string   "continent_name", limit: 25
    t.integer  "rank",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_countries", force: :cascade do |t|
    t.string   "country_code",       limit: 2
    t.string   "country_name",       limit: 100
    t.boolean  "has_geo_data",       limit: 1
    t.string   "short_country_name", limit: 40
    t.integer  "geo_continent_id",   limit: 4
    t.integer  "dial_code",          limit: 4
    t.boolean  "has_geo_regions",    limit: 1
    t.integer  "rank",               limit: 4
    t.integer  "rank_level",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_countries", ["country_code"], name: "country_code_opt", unique: true, using: :btree

  create_table "geo_regions", force: :cascade do |t|
    t.string   "region_name",       limit: 35
    t.string   "short_region_name", limit: 25
    t.integer  "geo_country_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_regions", ["geo_country_id"], name: "regions_country_code_opt", using: :btree

  create_table "locations", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.string   "name",                 limit: 70
    t.string   "address",              limit: 255
    t.string   "formatted_address",    limit: 255
    t.integer  "geo_area_id",          limit: 4
    t.string   "privacy",              limit: 24
    t.integer  "category_id",          limit: 4
    t.boolean  "is_private_residence", limit: 1
    t.string   "state",                limit: 24
    t.string   "editable_by",          limit: 24
    t.integer  "owner_user_id",        limit: 4
    t.float    "latitude",             limit: 24
    t.float    "longitude",            limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",                 limit: 4
    t.integer  "default_profile_view_id", limit: 4
    t.string   "short_description",       limit: 255
    t.text     "long_description",        limit: 65535
    t.boolean  "enable_personal",         limit: 1,     default: false
    t.boolean  "enable_business",         limit: 1,     default: false
    t.boolean  "enable_resume",           limit: 1,     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "profile_user_id_opt", using: :btree

  create_table "remote_event_api_sources", force: :cascade do |t|
    t.integer  "remote_event_api_id", limit: 4,                     null: false
    t.integer  "rank",                limit: 4
    t.string   "url",                 limit: 255,                   null: false
    t.text     "event_api_url",       limit: 65535
    t.text     "rsvp_api_url",        limit: 65535
    t.string   "event_source_id",     limit: 56
    t.string   "title",               limit: 255
    t.text     "description",         limit: 65535
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "last_modified"
    t.integer  "utc_offset",          limit: 4
    t.string   "timezone",            limit: 124
    t.string   "group_name",          limit: 255
    t.string   "group_url",           limit: 255
    t.boolean  "is_primary_event",    limit: 1,     default: false
    t.boolean  "announced",           limit: 1
    t.datetime "announced_at"
    t.string   "how_to_find_us",      limit: 255
    t.string   "publish_status",      limit: 24
    t.string   "venue_visiblity",     limit: 24
    t.string   "visibilty",           limit: 24
    t.integer  "yes_rsvp_count",      limit: 4
    t.string   "fee_accepts",         limit: 16
    t.float    "fee_amount",          limit: 24
    t.string   "fee_currency",        limit: 16
    t.string   "fee_description",     limit: 24
    t.string   "fee_label",           limit: 16
    t.boolean  "fee_required",        limit: 1
    t.integer  "remote_group_id",     limit: 4
    t.integer  "event_venue_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remote_event_apis", force: :cascade do |t|
    t.integer  "remote_event_id",                limit: 4
    t.string   "remote_source",                  limit: 126
    t.text     "options",                        limit: 65535
    t.string   "primary_remote_event_source_id", limit: 56
    t.integer  "primary_remote_event_index",     limit: 4,     default: 0
    t.text     "all_events_api_url",             limit: 65535
    t.text     "all_rsvps_api_url",              limit: 65535
    t.string   "api_key",                        limit: 255
    t.boolean  "remember_api_key",               limit: 1,     default: false
    t.boolean  "set_remote_date",                limit: 1
    t.boolean  "set_remote_venue",               limit: 1
    t.boolean  "set_remote_description",         limit: 1
    t.boolean  "set_remote_fee",                 limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remote_groups", force: :cascade do |t|
    t.string   "name",                        limit: 255
    t.string   "remote_source",               limit: 126
    t.text     "description",                 limit: 65535
    t.integer  "remote_group_id",             limit: 4
    t.string   "urlname",                     limit: 255
    t.string   "link",                        limit: 255
    t.string   "join_mode",                   limit: 24
    t.string   "visibility",                  limit: 24
    t.integer  "members",                     limit: 4
    t.integer  "remote_organizer_profile_id", limit: 4
    t.float    "lat",                         limit: 24
    t.float    "lon",                         limit: 24
    t.string   "timezone",                    limit: 124
    t.string   "state",                       limit: 100
    t.string   "city",                        limit: 200
    t.string   "country",                     limit: 100
    t.integer  "geo_area_id",                 limit: 4
    t.datetime "created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_groups", ["geo_area_id"], name: "remote_groups_geo_area_opt", using: :btree
  add_index "remote_groups", ["remote_group_id"], name: "remote_groups_groupid_opt", using: :btree
  add_index "remote_groups", ["remote_organizer_profile_id"], name: "remote_groups_orgprofile_opt", using: :btree

  create_table "remote_members", force: :cascade do |t|
    t.string   "name",                limit: 126
    t.string   "remote_source",       limit: 126
    t.integer  "remote_member_id",    limit: 4
    t.integer  "geo_area_id",         limit: 4
    t.string   "bio",                 limit: 255
    t.string   "country",             limit: 100
    t.string   "city",                limit: 200
    t.string   "state",               limit: 100
    t.string   "gender",              limit: 16
    t.string   "hometown",            limit: 200
    t.float    "lat",                 limit: 24
    t.float    "lon",                 limit: 24
    t.datetime "joined"
    t.string   "link",                limit: 255
    t.integer  "membership_count",    limit: 4
    t.string   "photo_high_res_link", limit: 255
    t.integer  "photo_id",            limit: 4
    t.string   "photo_link",          limit: 255
    t.string   "photo_thumb_link",    limit: 255
    t.datetime "last_visited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_members", ["geo_area_id"], name: "remote_members_geo_area_opt", using: :btree
  add_index "remote_members", ["remote_member_id", "remote_source"], name: "remote_member_id", unique: true, using: :btree
  add_index "remote_members", ["remote_member_id"], name: "remote_members_memid_opt", using: :btree

  create_table "remote_profiles", force: :cascade do |t|
    t.integer  "remote_member_id",    limit: 4
    t.integer  "remote_group_id",     limit: 4
    t.string   "bio",                 limit: 255
    t.string   "role",                limit: 16
    t.string   "comment",             limit: 255
    t.datetime "created"
    t.datetime "last_updated"
    t.string   "photo_high_res_link", limit: 255
    t.string   "photo_link",          limit: 255
    t.string   "photo_thumb_link",    limit: 255
    t.integer  "photo_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_profiles", ["remote_group_id"], name: "remote_profiles_groupid_opt", using: :btree
  add_index "remote_profiles", ["remote_member_id"], name: "remote_profiles_memid_opt", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "saved_excluded_remote_members", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "remote_member_id", limit: 4
    t.string   "exclude_type",     limit: 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_excluded_remote_members", ["user_id"], name: "saved_excluded_members_remotemem_opt", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                     limit: 32
    t.string   "email",                    limit: 50
    t.string   "username",                 limit: 24
    t.string   "gender",                   limit: 20
    t.date     "birthdate"
    t.string   "avatar",                   limit: 255
    t.string   "avatar_type",              limit: 255
    t.string   "time_zone",                limit: 255
    t.string   "password_digest",          limit: 255
    t.string   "remember_token",           limit: 255
    t.string   "auth_token",               limit: 255
    t.string   "validation_token",         limit: 255
    t.string   "password_reset_token",     limit: 255
    t.datetime "password_reset_sent_at"
    t.string   "email_validation_token",   limit: 255
    t.string   "ip_address_created",       limit: 255
    t.string   "ip_address_last_modified", limit: 255
    t.string   "ip_address_last_login",    limit: 255
    t.boolean  "email_validated",          limit: 1,   default: false
    t.datetime "email_validated_at"
    t.datetime "email_changed_at"
    t.boolean  "admin",                    limit: 1,   default: false
    t.datetime "last_login_at"
    t.boolean  "is_verified",              limit: 1
    t.boolean  "birthdate_is_verified",    limit: 1
    t.datetime "date_verified"
    t.integer  "verified_by_id",           limit: 4
    t.integer  "age",                      limit: 4
    t.datetime "age_last_checked"
    t.string   "age_display_type",         limit: 32
    t.integer  "geo_country_id",           limit: 4
    t.integer  "geo_area_id",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
