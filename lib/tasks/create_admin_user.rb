namespace :db do
  desc: "Create and Admin User for site"
  task :create_admin_user, [:name, :password] => :environment do |t, args|
    p "args = #{args}"

    user_name = args[:name]
    user_password = args[:password] 

    unless user_name
      puts "ERROR! no user_name given!"
      next
    end
    
    unless user_password
      puts "ERROR! no user_password given!"
      next
    end

end