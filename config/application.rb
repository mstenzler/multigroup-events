require File.expand_path('../boot', __FILE__)

require 'rails/all'
#require 'config_sanitizer'
#include ConfigSanitizer

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

CONFIG = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))
CONFIG.merge! CONFIG.fetch(Rails.env, {})
CONFIG.symbolize_keys!

class ConfigError < StandardError
end

module MultigroupEvents
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.after_initialize do
        #p "min_age = #{CONFIG[:min_age]}, enable_birthdate = #{CONFIG[:enable_birthdate?]}"
        #If we have min_age or max_age set, then we must also set enable_birthdate? to true
        #if ( (CONFIG[:min_age] || CONFIG[:max_age]) && (!CONFIG[:enable_birthdate?]) )
        #    raise ConfigError, "CONFIG[:enable_birthdate] must be true to use min_age or max_age"
        #end
        require 'config_sanitizer'
        include ConfigSanitizer
        check_config(CONFIG)
    end

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)
    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/app/models/events)
    I18n.enforce_available_locales = true
  end
end
