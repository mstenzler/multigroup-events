class RemoteEventApi < ActiveRecord::Base
  belongs_to :remote_event
#  has_many :remote_event_api_details, :dependent => :delete_all
  has_many :remote_event_api_sources, inverse_of: :remote_event_api, :dependent => :delete_all
  accepts_nested_attributes_for :remote_event_api_sources, allow_destroy: true, update_only: true

  DEFAULT_PRIMARY_REMOTE_EVENT_INDEX = 0

  attr_accessor :sources_by_id_hash, :primary_source

#  before_validate :populate_ranks
  before_save :catalog_sources
  before_save :load_api

  validates :api_key, presence: true
  validates_associated :remote_event_api_sources

  def event_id_list
    remote_event_api_sources.map { |rs| p "**rs** destroyed? = #{rs._destroy}"}
    remote_event_api_sources.reject { |rs| rs._destroy == true }.map { |rs| rs.event_source_id }
  end

  #returns the highest rank in the list of remote_event_api_sources
  def last_rank
    high = 0
    if (remote_event_api_sources && (remote_event_api_sources.size > 0))
      p "*** In last_rank. num remote_event_api_sources = #{remote_event_api_sources.size}"
      remote_event_api_sources.each { |rs| rnk = rs.rank; p "rnk = #{rnk}"; high = ( ((!rnk.nil?) && (rnk > high)) ? rnk : high) }
      if (high < remote_event_api_sources.size)
        high = remote_event_api_sources.size
      end
    end
    high
  end

  def get_source_by_event_id(event_id)
    unless (event_id.is_a? Symbol)
      event_id = event_id.to_sym
    end
    @sources_by_id_hash[event_id]
  end

  private

    def catalog_sources
      id_hash = {}
      remote_event_api_sources.each do |api_source|
        if (curr_id = api_source.event_source_id)
          id_hash[curr_id.to_sym] = api_source
        else
          raise "Could not get event_source_id from source #{api_source.inspect}"
        end
        if (api_source.is_primary?)
          self.primary_source = api_source
        end
      end
      self.sources_by_id_hash = id_hash
    end

    def load_api
      rclient = CCMeetup::Client.new({ auth_method: :api_key, api_key: api_key })
      re = CCRemoteEvent::ApiBuilder.new({ api_client: rclient, remote_event_api: self })
      re.load(:meetup, { get_signed_url: true})
    end

    def populate_api_old
      logger.debug("****IN populate_api")
#      logger.debug(remote_event_api)
 #     re_api = remote_event_api || RemoteEventApi.new
  #    re_api.remote_event_id = self.id
  #    if remember_api_key == 1
  #      re_api.api_key = remote_api_key
  #    end
  
  ##    event_urls = []
  ##    linked_events.map { |e| event_urls << e.url  }

      rclient = CCMeetup::Client.new({ auth_method: :api_key, api_key: api_key })
      re = CCRemoteEvent::ApiBuilder.new(rclient)
      api = re.build(:meetup, { get_signed_url: true, url_list: event_urls, remember_api_key: remote_event_api.remember_api_key })
      primary_event_index = api.primary_remote_event_index
      primary_event = api.remote_event_api_details[primary_event_index]
      logger.debug("primary_event =")
      logger.debug(primary_event)
      primary_start_date = api.remote_event_api_details[primary_event_index].start_date
      #logger.debug("primary_start_date = " + primary_start_date)
      if (primary_start_date)
        logger.debug("!! Setting start date!!!")
        self.start_date = primary_start_date
      end
      if (primary_end_date = api.remote_event_api_details[primary_event_index].end_date)
        self.end_date = primary_end_date
      end
      self.remote_event_api = api
    end

end
