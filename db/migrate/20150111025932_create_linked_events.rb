class CreateLinkedEvents < ActiveRecord::Migration
  def change
    create_table :linked_events do |t|
      t.integer :event_id, null: false
      t.string :url, null: false
      t.string :remote_event_id
      t.string :source
      t.integer :rank

      t.timestamps
    end
  end
end
