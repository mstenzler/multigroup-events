class EventsController < ApplicationController
  before_filter(only: [:new, :edit, :create, :update, :reload_api]) { signed_in_auth_user Authentication::MEETUP_PROVIDER_NAME, { require_access_token: true} }
  before_filter :signed_in_user, only: [:destroy, :rsvp_print]
#  before_filter :signed_in_user, :except => [:index, :index_tab, :show]
  before_filter :load_event, only: [:show, :rsvp_print, :edit, :update, :reload_api, :destroy]
  before_filter :check_privileges!, only: [:new, :create, :edit, :update, :destroy, :rsvp_print, :reload_api]
#  before_filter :load_auth, :only => [:new, :edit]
  layout "minimal", only: [:rsvp_print]

  PAGINATION_PAGE_PARAM = CONFIG[:pagination_page_param].to_sym
  PAGINATION_PER_PAGE =   CONFIG[:evetns_pagination_per_page]
  CALENDAR_START_DATE = CONFIG[:calendar_start_date] ? CONFIG[:calendar_start_date].to_date : "01-06-2015".to_date
  CALENDAR_NUM_YEARS_TO_SHOW = CONFIG[:calendar_num_years_to_show ] || 10
  CALENDAR_END_DATE = CALENDAR_START_DATE >> (12*CALENDAR_NUM_YEARS_TO_SHOW)

  class InvalidEventTypeError  < StandardError; end

  def index
   index_tab
  end

  def index_tab
    tab = params[:tab] || EventView::DEFAULT_VIEW
    unless tab
      display_error("No Tab Specified")
      return
    end
    @event_view = EventView.new(tab)

    case tab.downcase
    when Event::EVENT_TAB_UPCOMING
      @events = Event.listed.upcoming.paginate(page: params[PAGINATION_PAGE_PARAM], per_page: PAGINATION_PER_PAGE )
    when Event::EVENT_TAB_PAST
      @events = Event.listed.past.paginate(page: params[PAGINATION_PAGE_PARAM], per_page: PAGINATION_PER_PAGE )
    when Event::EVENT_TAB_CALENDAR
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @events_by_date = Event.by_month(@date).group_by { |i| i.start_date_local.to_date }
      check_start_end_date(@date)
#      @calendar_start_date = CALENDAR_START_DATE
#      @calendar_end_date = CALENDAR_END_DATE
    when Event::EVENT_TAB_MINE
      signed_in_user
      @events = Event.by_user(current_user)
    else
      display_error("Invalid event tab")
      return
    end
    render :index
  end

  def show
  end

  def rsvp_print
 #   authorize! :manage, @event
  end

  def new
#    authorize! :create, Event
    begin
      @event = new_event(params[:type])
      @api_keys = get_api_keys
    rescue InvalidEventTypeError => e
      flash.now[:error] = e.message
      @event = new_event()
    end
  end

  def create
 #   authorize! :create, Event
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    @event.current_user = current_user
    if @event.save
      flash[:success] = "Your Event has been created!"
      redirect_to @event
    else
      logger.debug("%$%$%$%$%$%$%$%$%$%$%$%$%$%")
      logger.debug("event.remote_event_api.remote_event_api_sources = #{@event.remote_event_api.remote_event_api_sources.inspect}")
      @api_keys = get_api_keys
  #    load_auth
      remove_remote_member_ids(@event)
      render 'new'
    end
  end

  def edit
#    authorize! :edit, @event
    build_excluded_members(@event)

    @api_keys = get_api_keys
  end

  def update
#    authorize! :update, @event
    if @event.update_attributes(event_params)
      flash[:success] = "Your Event has been updated!"
      redirect_to @event
      #redirect_to edit_user_url(@user), :notice => "Username has been changed."
    else
      load_auth
      render :edit
    end
  end

  def reload_api
 #   authorize! :update, @event
    if (api = @event.try(:remote_event_api))
      api.reload_api
      @event.save!
    end
    redirect_to @event
  end

  def destroy
    authorize! :destroy, @event
    logger.debug("About to desroy event: ")
    logger.debug(@event)
    @event.destroy
    redirect_to events_url, :notice => "Successfully deleted event."
  end

  private
    def check_privileges!
      authorize! :manage, @event, :message => "You are not authorized to perform this action!"
    end

    def check_start_end_date(date)
      #today = Date.today
#      logger.debug("-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=")
#      logger.debug("***---** In check_start_end_date!! date = #{date}")
      @show_previous_month = false
      @show_next_month = false
      curr_month = date.beginning_of_month
      prev_month = curr_month << 1
#      logger.debug("curr_month = #{curr_month}")
#      logger.debug("prev_month = #{prev_month}")
#      logger.debug("CALENDAR_START_DATE = #{CALENDAR_START_DATE}")
#      logger.debug("CALENDAR_END_DATE = #{CALENDAR_END_DATE}")
      if (prev_month >= CALENDAR_START_DATE)
        logger.debug("Setting @show_previous_month to true")
        @show_previous_month = true
      end
      if (curr_month < CALENDAR_END_DATE)
        logger.debug("Setting @show_next_month to true")
        @show_next_month = true
      end
    end

    def remove_remote_member_ids(event)
#      logger.debug("%$%$%$%$%$%$%$%$%$%$%$%$%$%")
#      logger.debug("In remote_remote_member_ids")
      event.excluded_remote_members.each do |erm|
#        logger.debug("erm = #{erm.inspect}")
        curr_remote_member_id = erm.remote_member.remote_member_id
#        logger.debug("curr_remote_member_id = #{curr_remote_member_id}")
        erm.remote_member_id = nil
        erm.build_remote_member(remote_member_id: curr_remote_member_id)
#        logger.debug("After remove erm = #{erm.inspect}")
      end
    end

    def load_auth
      logger.debug("++**++!!!!! in load_auth")
      @user = current_user
      auth = @user.authentications.by_provider('meetup').first
      logger.debug("auth = #{auth}")
      if (auth)
        @access_token = auth.get_fresh_token
        logger.debug("Fresh Access Token = #{@access_token}")
        if (@access_token)
          logger.debug("Setting auth = #{auth.inspect}")
          @auth = auth
        end
      end
    end

    def load_event
      @event = Event.friendly.find(params[:id])
      @event.current_user = current_user
      @event.populate_excluded=true
      logger.debug("*** Loaded event = #{@event.inspect}")
    end

    def build_excluded_members(event)
  #    p "**__** in build_excluded_members!!"
      if (!event.excluded_remote_members)
  #      p "No excluded_remote_members. building from scratch"
        event.build_excluded_remote_members.build_remote_member
      elsif (event.excluded_remote_members.length > 0)
  #      p "Have excluded_remote_members. iterating"
        event.excluded_remote_members.each do |erm|
  #        p "erm = #{erm.inspect}"
          if (!erm.remote_member)
 #           p "buiding erm.remote_member"
            erm.build_remote_member
          end
        end
      else
#        p "Have no excluded members"
        event.excluded_remote_members.build.build_remote_member
      end
    end

    def new_event(type=nil)
      puts "in new_event. type = '#{type}'"
      ret = nil
      if (type)
        if (Event.valid_event_type?(type))
          ret = type.constantize.new
          ret.type = type
 #         p "new event = #{ret}, type = #{type}"
        else
  #        puts "About to raise InvalidEventTypeError"
          raise InvalidEventTypeError.new "Invalid event Type '#{type}'"
        end
      else
        puts "About to return new Event"
        ret = Event.new
      end
      # create a blank linked event so that the form shows a 
      # blank field to start
#      ret.linked_events << LinkedEvent.new
      ret.user_id = current_user.id
      if ret.event_type.is_remote?
        puts "event is remote!!!!"
        api_source = RemoteEventApiSource.new(is_primary_event: true, rank: 1)
#        puts("api_source = #{api_source.inspect}")
        ret.build_remote_event_api(remote_source: RemoteEvent::MEETUP_NAME)
        #ret.remote_event_api.remote_event_api_sources << RemoteEventApiSource.new(is_primary_event: true, rank: 1)
        ret.remote_event_api.remote_event_api_sources << api_source
 #       remote_member = new RemoteMember(remote_source: RemoteEvent::MEETUP_NAME)
 #       ret.build_excluded_guests( exclude_type: ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE).build_remote_member(remote_source: RemoteEvent::MEETUP_NAME)
 #       ret.excluded_guests.build(exclude_type: ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE).remote_member.build(remote_source: RemoteEvent::MEETUP_NAME)
 #     ret.excluded_guests.build(exclude_type: ExcludedRemoteMember::EXCLUDE_GUESTS_TYPE).build_remote_member(remote_source: RemoteEvent::MEETUP_NAME)
       #ret.excluded_remote_members.build
        build_excluded_members(ret)
#        ret.excluded_guests.exclude_guests
      end
      ret
    end

    def get_api_keys(return_empty_list=false)
      ret = nil
      if (current_user)
        ret = current_user.auth_api_keys
      end
      if !return_empty_list
        #set ret to nil if there is not at least one key
        unless (ret && ret.size > 0)
          ret = nil
        end
      end
      ret
    end

=begin
    def add_existing_remote_member_ids_to_params
      logger.debug("**--^%^%^$ in add to params. params = #{params[:event].inspect}")
      params[:event][:excluded_remote_members_attributes].each do |key, val|
        logger.debug("==-==-- val (#{val.class.name}) = #{val.inspect}")
        logger.debug("val[:remote_member_attributes] (#{val[:remote_member_attributes].class.name}) = #{val[:remote_member_attributes]}")
        remote_member = val[:remote_member_attributes]
        logger.debug("remote_member (#{remote_member.class.name}= #{remote_member.inspect}")
        curr_source = remote_member['remote_source']
        curr_id = remote_member['remote_member_id']
        if (curr_source && curr_id)
          curr_member = RemoteMember.where(remote_source: curr_source, 
                                       remote_member_id: curr_id).first
          logger.debug("**--^%^%^$ in add to params. curr_member = #{curr_member.inspect}")
           if (curr_member)
            logger.debug("Addinge remote_member.id = #{curr_member.id}")
             #val['remote_member_ids'] = [curr_member.id]
             new_id = ActiveSupport::HashWithIndifferentAccess.new('remote_member_ids' => [curr_member.id])
             val.replace(new_id.update(val))
             remote_member['id'] = curr_member.id
          end
        end
      end
    end
=end

    def event_params
      params.require(:event).permit(:type, :url_identifier, :remote_api_key, :display_listing, 
             :remember_api_key, :display_privacy, :display_list, :title, 
             :description, :start_date, :end_date, :location_id,
             linked_events_attributes: [:url, :id],
             excluded_remote_members_attributes: [:id, :_destroy, :exclude_type, remote_member_attributes: [:id, :remote_source, :remote_member_id]],
             remote_event_api_attributes: [:api_key, :remember_api_key, 
              :remote_source,:id, 
              remote_event_api_sources_attributes: [:url, :is_primary_event, :id, :_destroy, :rank]])
    end
    
end