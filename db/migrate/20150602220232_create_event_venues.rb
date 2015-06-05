class CreateEventVenues < ActiveRecord::Migration
  def change
    create_table :event_venues do |t|
      t.string :geo_area_id
      t.string :remote_source, :limit => 64
      t.integer :remote_id
      t.string :zip, :limit => 10
      t.string :phone, :limit => 24
      t.float :lon
      t.float :lat
      t.string :name
      t.string :state, :limit => 20
      t.string :city, :limit => 80
      t.string :country, :limit => 2
      t.string :address_1, :limit => 128
      t.string :address_2, :limit => 128
      t.string :address_3, :limit => 128
      t.string :privacy, :limit => 24
      t.boolean :is_private_residence
      t.string :editable_by,  :limit => 24
      t.timestamps
    end
  end
end
