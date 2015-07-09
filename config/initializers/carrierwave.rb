CarrierWave.configure do |config|
  # These permissions will make dir and files available only to the user running
  # the servers
  #config.permissions = 0600
  config.permissions = 0644
 # config.directory_permissions = 0700
  config.directory_permissions = 0755
  config.storage = :file
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  #config.root = Rails.root
end

if Rails.env.test? || Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end

  # make sure our uploader is auto-loaded
  AvatarUploader

  # use different dirs when testing
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      end
    end
  end
end