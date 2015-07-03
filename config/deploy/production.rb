set :stage, :production
set :branch, "master"

set :server_name, "www.multigroupevents.com, multigroupevents.com"

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

server 'multigroupevents.com', user: 'deploy', roles: %w{web app db}, primary: true

set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"

#don't try and infer something as important as environment from stage name
set :rails_env, :production

#the number of unicor workers, this will be reflected in the
#unicorn.rb and mont configs
set :unicorn_worker_count, 5

#whether we're using ssl or not, used for building ngink config file
set :enable_ssl, false
