class CreateRemoteMembers < ActiveRecord::Migration
  def change
    create_table :remote_members do |t|
      t.string :name, :limit => 126
      t.string :remote_source, :limit => 126
      t.integer :remote_member_id
      t.integer :geo_area_id
      t.string :bio
      t.string :country,  :limit => 100
      t.string :city,  :limit => 200
      t.string :state,  :limit => 100
      t.string :gender,  :limit => 16
      t.string :hometown,  :limit => 200
      t.float :lat
      t.float :lon
      t.datetime :joined
      t.string :link
      t.integer :membership_count
      t.string :photo_high_res_link
      t.integer :photo_id
      t.string :photo_link
      t.string :photo_thumb_link
      t.datetime :last_visited

      t.timestamps
    end

    add_index "remote_members", ["remote_member_id", "remote_source"], :unique => true, :name => "remote_members_memid_opt"
    add_index "remote_members", ["geo_area_id"], :name => "remote_members_geo_area_opt"

  end
end
