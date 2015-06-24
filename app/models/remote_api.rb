class RemoteApi

  REMOTE_SOURCES = CONFIG[:remote_api_sources]
#  logger.debug("remote_sorces =#{REMOTE_SOURCES.inspect}" )
  MEETUP_NAME = REMOTE_SOURCES['meetup']['name']
  MEETUP_URI_HOST = REMOTE_SOURCES['meetup']['uri_host']
  FACEBOOK_NAME = REMOTE_SOURCES['facebook']['name']
  FACEBOOK_URI_HOST = REMOTE_SOURCES['facebook']['uri_host']

end
