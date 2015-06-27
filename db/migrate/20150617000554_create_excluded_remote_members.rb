class CreateExcludedRemoteMembers < ActiveRecord::Migration
  def change
    create_table :excluded_remote_members do |t|
      t.integer :remote_member_id
      t.integer :event_id
      t.string :exclude_type,  :limit => 16

      t.timestamps
    end

    add_index "excluded_remote_members", ["remote_member_id"], :name => "excluded_members_remotemem_opt"
    add_index "excluded_remote_members", ["event_id"], :name => "excluded_members_event_opt"

  end
end
