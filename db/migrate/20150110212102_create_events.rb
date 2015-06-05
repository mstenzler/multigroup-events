class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id, null: false
      t.string :type
      t.string :title, null: false
      t.string :slug, null: false
      t.string :fee, :limit => 124
      t.text :description
      t.string :display_privacy, default: "public"
      t.boolean :display_listing, default: true
      t.datetime :start_date
      t.datetime :end_date
      t.float  :fee_amount
      t.string :fee_currency, :limit => 16
      t.string :fee_description, :limit => 24
      t.string :fee_label, :limit => 16
      t.boolean :fee_required
      t.integer :event_venue_id
      t.string :remote_event_api_id

      t.timestamps
    end

    add_index "events", ["user_id"], name: "user_opt"
    add_index "events", ["start_date"], name: "start_date_opt"
    add_index "events", ["slug"], name: "slug_opt", unique: true
  end
end
