# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

require 'yaml'

  VALID_DATA_FILE_TYPES = ["csv", "yml"]

  CSV_FILE_TYPE = VALID_DATA_FILE_TYPES[0]
  YML_FILE_TYPE = VALID_DATA_FILE_TYPES[1]

  config   = Rails.configuration.database_configuration
  host     = config[Rails.env]["host"]
  database = config[Rails.env]["database"]
  username = config[Rails.env]["username"]
  password = config[Rails.env]["password"]

  Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::LOCAL_FILES
#  connection = ActiveRecord::Base.connection()
  client =   ActiveRecord::Base.establish_connection(adapter: "mysql2", username: username, host: host, password: password, database: database, local_infile: true)
  connection = client.connection

  yml = YAML.load_file "#{Rails.root}/db/seed_data/tables.yml"
  p "got yml file"
  yml.each_key do |table_name|
    p "working on table: #{table_name}"

    table_enabled  = yml[table_name]['enabled']

    if table_enabled

      fields_arr     = yml[table_name]['fields']
      delimiter      = yml[table_name]['delimiter']
      terminated_by  = yml[table_name]['terminated_by']
      data_file_type = yml[table_name]['data_file_type']
      data_file      = yml[table_name]['data_file'] || "#{Rails.root}/db/seed_data/#{table_name}.csv"
      reset_auto_increment = yml[table_name]['reset_auto_increment'] || false
      update_time = yml[table_name]['update_time'] || false

      fields = "(" + fields_arr.join(', ') + ")"
   
      p "working on data_file: #{data_file}"
  #    p " deliiter = '#{delimiter}', terminated_by = '#{terminated_by}'"

      if (data_file && (VALID_DATA_FILE_TYPES.include? data_file_type) )
        #truncate the table
        table_name.classify.constantize.delete_all
        p "truncated table #{table_name}"
    
        if reset_auto_increment
          connection.execute "alter table #{table_name} auto_increment=1"
        end   

        case data_file_type
          when CSV_FILE_TYPE
            sql =  "LOAD DATA LOCAL INFILE '#{data_file}' INTO TABLE #{table_name} FIELDS " +
                  "TERMINATED BY '#{delimiter}' " +
                  "LINES TERMINATED BY '#{terminated_by}' " + fields
            p "sql = " + sql
            connection.execute sql
            p "Loaded table: #{table_name}"
          when YML_FILE_TYPE
            p "yml not yet implemented!"
        end #case data_file_type

        if update_time
          connection.execute "update #{table_name} set updated_at = NOW(), created_at = NOW()"
        end   

      else
        p "ERROR: Invalid data file type or no data file"
      end # if data_file and valid type

    else
      p "Skipping table #{table_name} (disabled)"
    end

  end #yml.each_key