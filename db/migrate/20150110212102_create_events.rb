class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id, null: false
      t.string :type
      t.string :title, null: false
      t.string :slug, null: false
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :location_id
      t.string :remote_event_api_id

      t.timestamps
    end

    add_index "events", ["user_id"], name: "user_opt"
    add_index "events", ["slug"], name: "slug_opt", unique: true
  end
end
