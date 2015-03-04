source 'https://rubygems.org'
ruby '2.0.0'
#ruby-gemset=rails-4-template

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.6'


# Use sqlite3 as the database for Active Record
#gem 'sqlite3'
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
 gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '3.0.4'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

#group :assets do
#  gem 'ejs'
#end

group :development do
  gem 'nifty-generators'
  gem 'populator'
  gem 'faker'
  gem 'rename'
  gem 'random_data'
  gem 'rails-erd'
end

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
  gem 'selenium-webdriver', '>= 2.35.1'
  gem 'capybara', '>= 2.1.0'
  gem 'guard-rspec', '>= 2.5.0'
  # Uncomment these lines on Linux.
  gem 'libnotify', '>= 0.8.0'
  # Uncomment this line on OS X.
  # gem 'growl', '1.0.3'
  gem 'spork-rails', '>= 4.0.0'
  gem 'guard-spork', '>= 1.5.0'
  gem 'childprocess', '>= 0.3.6'
  gem 'database_cleaner', '>= 1.2.0'
  gem 'rspec-its'
end

gem 'geokit', '~> 1.9.0'
gem 'geocoder'
gem 'bootstrap-sass', '~> 3.2.0'
gem 'bootstrap_form', '~> 2.2.0'
gem 'autoprefixer-rails'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'validates_timeliness', github: 'adzap/validates_timeliness', branch: 'rails4'

# Use ActiveModel has_secure_password
gem 'bcrypt'
#gem 'carrierwave'
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave', ref: 'c2ee2e8'
gem 'mini_magick'

gem 'omniauth-meetup'
#gem 'omniauth-twitter'
gem 'omniauth-facebook'
#gem 'twitter'
gem 'fb_graph'
gem 'rest-client'
gem 'friendly_id', '~> 5.0.0'

group :development, :test do
  gem 'rspec-rails', '>= 2.13.1'
  gem "factory_girl_rails", '>= 4.2.0'
  gem 'launchy'
end

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem "mocha", group: :test