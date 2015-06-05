class RemoteEventApi < ActiveRecord::Base
  belongs_to :remote_event, inverse_of: :remote_event_api
#  has_many :remote_event_api_details, :dependent => :delete_all
  has_many :remote_event_api_sources, -> { order(:rank) }, inverse_of: :remote_event_api, :dependent => :delete_all
  accepts_nested_attributes_for :remote_event_api_sources, allow_destroy: true, update_only: true

  DEFAULT_PRIMARY_REMOTE_EVENT_INDEX = 0
  SET_REMOTE_DATE_DEFAULT = true
  SET_REMOTE_VENUE_DEFAULT = true
  SET_REMOTE_DESCRIPTION_DEFAULT = true
  SET_REMOTE_FEE_DEFAULT = true

  attr_accessor :sources_by_id_hash, :primary_source

#  before_validate :populate_ranks
  before_save :default_values
  before_save :catalog_sources
  before_save :load_api

  validates :api_key, presence: true
  validates_associated :remote_event_api_sources

  def primary_source
    @primary_source ||= get_primary_source
  end

  def get_primary_source
    logger.debug("** in get_primary_source")
    ret = nil
    if (remote_event_api_sources)
      ret = remote_event_api_sources[primary_remote_event_index]
    end
    ret
  end

  def set_primary_remote_event_index
    index = nil
    i=0
    remote_event_api_sources.each do |api_source|
      if (api_source.is_primary?)
        index = i
        break
      end
      i+=1
    end
    if (index)
      self.primary_remote_event_index = index
    else
      logger.warn("WARNING!! No primary source specified in #{self.inspect}")
    end
  end

  def primary_venue
    primary_source.event_venue
  end

  def event_group_list
    @event_group_list ||= get_event_group_list
  end

  def get_event_group_list
    ret = []
    remote_event_api_sources.each do |source|
      item = { group_name: source.group_name, url: source.url,
               yes_rsvp_count: source.yes_rsvp_count }
      ret << item
    end
    ret
  end

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
    id_hash = sources_by_id_hash
    unless (id_hash)
      catalog_sources
      id_hash = sources_by_id_hash
    end
    id_hash[event_id]
  end

  def reload_api
    load_api
  end

  private

    def default_values
      self.set_remote_date = SET_REMOTE_DATE_DEFAULT if self.set_remote_date.nil?
      self.set_remote_venue = SET_REMOTE_VENUE_DEFAULT if self.set_remote_venue.nil?
      self.set_remote_description = SET_REMOTE_DESCRIPTION_DEFAULT if self.set_remote_description.nil?
      self.set_remote_fee = SET_REMOTE_FEE_DEFAULT if self.set_remote_fee.nil?
    end

    def catalog_sources
      id_hash = {}
      i=0;
      remote_event_api_sources.each do |api_source|
        if (curr_id = api_source.event_source_id)
          id_hash[curr_id.to_sym] = api_source
          if (api_source.is_primary?)
            self.primary_source = api_source
            self.primary_remote_event_source_id = curr_id
            self.primary_remote_event_index = i
          end
        else
          raise "Could not get event_source_id from source #{api_source.inspect}"
        end
        i+=1
      end
      self.sources_by_id_hash = id_hash
    end

    def load_api
      rclient = CCMeetup::Client.new({ auth_method: :api_key, api_key: api_key })
      re = CCRemoteEvent::ApiBuilder.new({ api_client: rclient, remote_event_api: self })
      re.load(:meetup, { get_signed_url: true})
      ps = self.primary_source
      set_values_from_remote_source(remote_event, ps)
      logger.debug("primary source = #{ps.inspect}")
    end

    def set_values_from_remote_source(remote_event, source)
      logger.debug("primary source = #{source.inspect}")
      if (remote_event.nil?)
        raise "nil remote_event in #{self.class.name}.#{__method__}"
      end
      if (source.nil?)
        raise "nil source in #{self.class.name}.#{__method__}"
      end
      unless (remote_event.is_a? RemoteEvent)
        raise "Must pass an instance of RemoteEvent as first param to #{self.class.name}.#{__method__}"
      end
      unless (source.is_a? RemoteEventApiSource)
        raise "Must pass an instance of RemoteEventApiSource as second param to #{self.class.name}.#{__method__}"
      end
      if (set_remote_date)
        logger.debug("** seting remote DATE!")
        if (sd = source.start_date)
          logger.debug("Remote start date = #{sd}")
          remote_event.start_date = sd
        end
        if (ed = source.end_date)
          remote_event.end_date = ed
        end
      end
      if (set_remote_venue && venue = source.event_venue)
        remote_event.event_venue_id = venue.id
      end
      if (set_remote_description)
        logger.debug("Setting descripion =")
        logger.debug(source.description)
        remote_event.description = source.description if source.description
      end
      if (set_remote_fee)
        remote_event.fee_amount = source.fee_amount if source.fee_amount
        remote_event.fee_currency = source.fee_currency if source.fee_currency
        remote_event.fee_description = source.fee_description if source.fee_description
        remote_event.fee_label = source.fee_label if source.fee_label
        remote_event.fee_required = source.fee_required if !source.fee_required.nil?
      end
    end
end
 