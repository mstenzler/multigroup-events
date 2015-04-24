require 'yaml'
#example call: rake db:load_seed_table["nav_items"]

namespace :db do
  desc "Loads in one of the seed data tables"
  task :load_seed_table, [:tablename] => :environment do |t, args|
   p "args = #{args}"

    table_name = args[:tablename]

    unless table_name
      puts "ERROR! No tablename given!"
      return
    end

    VALID_DATA_FILE_TYPES = ["csv", "yml"]

    CSV_FILE_TYPE = VALID_DATA_FILE_TYPES[0]
    YML_FILE_TYPE = VALID_DATA_FILE_TYPES[1]

    puts "table_name = #{table_name}"

    yml = YAML.load_file "#{Rails.root}/db/seed_data/tables.yml"
    p "got yml file"

    p "working on table: #{table_name}"

    fields_arr     = yml[table_name]['fields']
    delimiter      = yml[table_name]['delimiter']
    terminated_by  = yml[table_name]['terminated_by']
    data_file_type = yml[table_name]['data_file_type']
    data_file      = yml[table_name]['data_file'] || "#{Rails.root}/db/seed_data/#{table_name}.csv"
    reset_auto_increment = yml[table_name]['reset_auto_increment'] || false
    update_time = yml[table_name]['update_time'] || false

    fields = "(" + fields_arr.join(', ') + ")"

    p "working on data_file: #{data_file}"

    if (data_file && (VALID_DATA_FILE_TYPES.include? data_file_type) )
      #truncate the table
      table_name.classify.constantize.delete_all
      p "truncated table #{table_name}"

      if reset_auto_increment
        ActiveRecord::Base.connection.execute "alter table #{table_name} auto_increment=1"
      end

      case data_file_type
        when CSV_FILE_TYPE
          sql =  "LOAD DATA INFILE '#{data_file}' INTO TABLE #{table_name} FIELDS " +
                "TERMINATED BY '#{delimiter}' " +
                "LINES TERMINATED BY '#{terminated_by}' " + fields
          p "sql = " + sql
          ActiveRecord::Base.connection.execute sql
          p "Loaded table: #{table_name}"
        when YML_FILE_TYPE
          p "yml not yet implemented!"
      end #case data_file_type

      if update_time
        ActiveRecord::Base.connection.execute "update #{table_name} set updated_at = NOW(), created_at = NOW()"
      end

    else
      p "ERROR: Invalid data file type or no data file"
    end # if data_file and valid type

  end
end
