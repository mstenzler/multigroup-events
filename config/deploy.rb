set :application, 'multigroupevents'
set :deploy_user, 'deploy'

#setup repo details
set :scm, :git
set :repo_url, 'git@github.com:mstenzler/multigroup-events.git'

#setup rvm
set :rbenv_type, :system
set :rbenv_ruby, '2.2.2'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}

# Default value for keep_releases is 5
set :keep_releases, 5

#files we want symlinking to specific entries in shared
set :linked_files, %w{config/database.yml config/secrets.yml}

#dirs we want symlinking to shared
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

#http://www.capistranob.com/documentatin/getting-started/flow
#is a quick overviewd of what tasks are called and
#when for 'cap stage deploy'

namespace :deploy do
end
