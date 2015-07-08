class AddUrlIdentifierToEvents < ActiveRecord::Migration
  def change
    add_column :events, :url_identifier, :string, :limit => 24
  end
end
