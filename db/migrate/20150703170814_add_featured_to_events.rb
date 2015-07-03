class AddFeaturedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :featured, :boolean, default: false
    add_column :events, :show_home_page, :boolean, default: true
    add_column :events, :priority, :integer, default: 0
  end
end
