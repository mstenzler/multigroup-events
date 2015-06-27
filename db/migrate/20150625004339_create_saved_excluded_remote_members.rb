class CreateSavedExcludedRemoteMembers < ActiveRecord::Migration
  def change
    create_table :saved_excluded_remote_members do |t|
      t.integer :user_id
      t.integer :remote_member_id
      t.string :exclude_type,  :limit => 16

      t.timestamps
    end

    add_index "saved_excluded_remote_members", ["user_id"], :name => "saved_excluded_members_remotemem_opt"

  end
end
