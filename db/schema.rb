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

ActiveRecord::Schema.define(version: 20150625004339) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.string   "token_secret"
    t.string   "refresh_token"
    t.string   "api_key"
    t.datetime "expires_at"
    t.boolean  "expires",       default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_venues", force: true do |t|
    t.string   "geo_area_id"
    t.string   "remote_source",        limit: 64
    t.integer  "remote_id"
    t.string   "zip",                  limit: 10
    t.string   "phone",                limit: 24
    t.float    "lon",                  limit: 24
    t.float    "lat",                  limit: 24
    t.string   "name"
    t.string   "state",                limit: 20
    t.string   "city",                 limit: 80
    t.string   "country",              limit: 2
    t.string   "address_1",            limit: 128
    t.string   "address_2",            limit: 128
    t.string   "address_3",            limit: 128
    t.string   "privacy",              limit: 24
    t.boolean  "is_private_residence"
    t.string   "editable_by",          limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: true do |t|
    t.integer  "user_id",                                            null: false
    t.string   "type"
    t.string   "title",                                              null: false
    t.string   "slug",                                               null: false
    t.string   "fee",                 limit: 124
    t.text     "description"
    t.string   "display_privacy",                 default: "public"
    t.boolean  "display_listing",                 default: true
    t.datetime "start_date"
    t.datetime "end_date"
    t.float    "fee_amount",          limit: 24
    t.string   "fee_currency",        limit: 16
    t.string   "fee_description",     limit: 24
    t.string   "fee_label",           limit: 16
    t.boolean  "fee_required"
    t.integer  "event_venue_id"
    t.string   "remote_event_api_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone",            limit: 124
    t.integer  "utc_offset"
  end

  add_index "events", ["slug"], name: "slug_opt", unique: true, using: :btree
  add_index "events", ["start_date"], name: "start_date_opt", using: :btree
  add_index "events", ["user_id"], name: "user_opt", using: :btree

  create_table "excluded_remote_members", force: true do |t|
    t.integer  "remote_member_id"
    t.integer  "event_id"
    t.string   "exclude_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "excluded_remote_members", ["event_id"], name: "excluded_members_event_opt", using: :btree
  add_index "excluded_remote_members", ["remote_member_id"], name: "excluded_members_remotemem_opt", using: :btree

  create_table "geo_areas", force: true do |t|
    t.integer  "geo_country_id"
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

  create_table "geo_cities", force: true do |t|
    t.string   "city_name",       limit: 80
    t.string   "short_city_name", limit: 60
    t.integer  "geo_region_id"
    t.integer  "geo_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_cities", ["geo_country_id", "geo_region_id"], name: "geo_cities_region_opt", using: :btree

  create_table "geo_continents", force: true do |t|
    t.string   "continent_name", limit: 25
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_countries", force: true do |t|
    t.string   "country_code",       limit: 2
    t.string   "country_name",       limit: 100
    t.boolean  "has_geo_data"
    t.string   "short_country_name", limit: 40
    t.integer  "geo_continent_id"
    t.integer  "dial_code"
    t.boolean  "has_geo_regions"
    t.integer  "rank"
    t.integer  "rank_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_countries", ["country_code"], name: "country_code_opt", unique: true, using: :btree

  create_table "geo_regions", force: true do |t|
    t.string   "region_name",       limit: 35
    t.string   "short_region_name", limit: 25
    t.integer  "geo_country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "geo_regions", ["geo_country_id"], name: "regions_country_code_opt", using: :btree

  create_table "locations", force: true do |t|
    t.integer  "user_id"
    t.string   "name",                 limit: 70
    t.string   "address"
    t.string   "formatted_address"
    t.integer  "geo_area_id"
    t.string   "privacy",              limit: 24
    t.integer  "category_id"
    t.boolean  "is_private_residence"
    t.string   "state",                limit: 24
    t.string   "editable_by",          limit: 24
    t.integer  "owner_user_id"
    t.float    "latitude",             limit: 24
    t.float    "longitude",            limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.integer  "default_profile_view_id"
    t.string   "short_description"
    t.text     "long_description"
    t.boolean  "enable_personal",         default: false
    t.boolean  "enable_business",         default: false
    t.boolean  "enable_resume",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "profile_user_id_opt", using: :btree

  create_table "remote_event_api_sources", force: true do |t|
    t.integer  "remote_event_api_id",                             null: false
    t.integer  "rank"
    t.string   "url",                                             null: false
    t.text     "event_api_url"
    t.text     "rsvp_api_url"
    t.string   "event_source_id",     limit: 56
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "last_modified"
    t.integer  "utc_offset"
    t.string   "timezone",            limit: 124
    t.string   "group_name"
    t.string   "group_url"
    t.boolean  "is_primary_event",                default: false
    t.boolean  "announced"
    t.datetime "announced_at"
    t.string   "how_to_find_us"
    t.string   "publish_status",      limit: 24
    t.string   "venue_visiblity",     limit: 24
    t.string   "visibilty",           limit: 24
    t.integer  "yes_rsvp_count"
    t.string   "fee_accepts",         limit: 16
    t.float    "fee_amount",          limit: 24
    t.string   "fee_currency",        limit: 16
    t.string   "fee_description",     limit: 24
    t.string   "fee_label",           limit: 16
    t.boolean  "fee_required"
    t.integer  "remote_group_id"
    t.integer  "event_venue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remote_event_apis", force: true do |t|
    t.integer  "remote_event_id"
    t.string   "remote_source",                  limit: 126
    t.text     "options"
    t.string   "primary_remote_event_source_id", limit: 56
    t.integer  "primary_remote_event_index",                 default: 0
    t.text     "all_events_api_url"
    t.text     "all_rsvps_api_url"
    t.string   "api_key"
    t.boolean  "remember_api_key",                           default: false
    t.boolean  "set_remote_date"
    t.boolean  "set_remote_venue"
    t.boolean  "set_remote_description"
    t.boolean  "set_remote_fee"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "remote_groups", force: true do |t|
    t.string   "name"
    t.string   "remote_source",               limit: 126
    t.text     "description"
    t.integer  "remote_group_id"
    t.string   "urlname"
    t.string   "link"
    t.string   "join_mode",                   limit: 24
    t.string   "visibility",                  limit: 24
    t.integer  "members"
    t.integer  "remote_organizer_profile_id"
    t.float    "lat",                         limit: 24
    t.float    "lon",                         limit: 24
    t.string   "timezone",                    limit: 124
    t.string   "state",                       limit: 100
    t.string   "city",                        limit: 200
    t.string   "country",                     limit: 100
    t.integer  "geo_area_id"
    t.datetime "created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_groups", ["geo_area_id"], name: "remote_groups_geo_area_opt", using: :btree
  add_index "remote_groups", ["remote_group_id"], name: "remote_groups_groupid_opt", using: :btree
  add_index "remote_groups", ["remote_organizer_profile_id"], name: "remote_groups_orgprofile_opt", using: :btree

  create_table "remote_members", force: true do |t|
    t.string   "name",                limit: 126
    t.string   "remote_source",       limit: 126
    t.integer  "remote_member_id"
    t.integer  "geo_area_id"
    t.string   "bio"
    t.string   "country",             limit: 100
    t.string   "city",                limit: 200
    t.string   "state",               limit: 100
    t.string   "gender",              limit: 16
    t.string   "hometown",            limit: 200
    t.float    "lat",                 limit: 24
    t.float    "lon",                 limit: 24
    t.datetime "joined"
    t.string   "link"
    t.integer  "membership_count"
    t.string   "photo_high_res_link"
    t.integer  "photo_id"
    t.string   "photo_link"
    t.string   "photo_thumb_link"
    t.datetime "last_visited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_members", ["geo_area_id"], name: "remote_members_geo_area_opt", using: :btree
  add_index "remote_members", ["remote_member_id"], name: "remote_members_memid_opt", using: :btree

  create_table "remote_profiles", force: true do |t|
    t.integer  "remote_member_id"
    t.integer  "remote_group_id"
    t.string   "bio"
    t.string   "role",                limit: 16
    t.string   "comment"
    t.datetime "created"
    t.datetime "last_updated"
    t.string   "photo_high_res_link"
    t.string   "photo_link"
    t.string   "photo_thumb_link"
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "remote_profiles", ["remote_group_id"], name: "remote_profiles_groupid_opt", using: :btree
  add_index "remote_profiles", ["remote_member_id"], name: "remote_profiles_memid_opt", using: :btree

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "saved_excluded_remote_members", force: true do |t|
    t.integer  "user_id"
    t.integer  "remote_member_id"
    t.string   "exclude_type",     limit: 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "saved_excluded_remote_members", ["user_id"], name: "saved_excluded_members_remotemem_opt", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                     limit: 32
    t.string   "email",                    limit: 50
    t.string   "username",                 limit: 24
    t.string   "gender",                   limit: 20
    t.date     "birthdate"
    t.string   "avatar"
    t.string   "avatar_type"
    t.string   "time_zone"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "auth_token"
    t.string   "validation_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "email_validation_token"
    t.string   "ip_address_created"
    t.string   "ip_address_last_modified"
    t.string   "ip_address_last_login"
    t.boolean  "email_validated",                     default: false
    t.datetime "email_validated_at"
    t.datetime "email_changed_at"
    t.boolean  "admin",                               default: false
    t.datetime "last_login_at"
    t.boolean  "is_verified"
    t.boolean  "birthdate_is_verified"
    t.datetime "date_verified"
    t.integer  "verified_by_id"
    t.integer  "age"
    t.datetime "age_last_checked"
    t.string   "age_display_type",         limit: 32
    t.integer  "geo_country_id"
    t.integer  "geo_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "users_roles", id: false, force: true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
