class EventsController < ApplicationController
  before_filter(only: [:new, :edit, :create, :update, :reload_api]) { signed_in_auth_user Authentication::MEETUP_PROVIDER_NAME, { require_access_token: true} }
  before_filter :signed_in_user, only: [:destroy, :rsvp_print]
#  before_filter :signed_in_user, :except => [:index, :index_tab, :show]
  before_filter :load_event, only: [:show, :rsvp_print, :edit, :update, :reload_api, :destroy]
  before_filter :check_privileges!, only: [:new, :create, :edit, :update, :destroy, :rsvp_print, :reload_api]
  before_filter :check_privacy, only: [:show]
  before_filter :check_display_listing, only: [:create, :update]
#  before_filter :load_auth, :only => [:new, :edit]
  layout "minimal", only: [:rsvp_print]

  PAGINATION_PAGE_PARAM = CONFIG[:pagination_page_param].to_sym
  PAGINATION_PER_PAGE =   CONFIG[:evetns_pagination_per_page]
  CALENDAR_START_DATE = CONFIG[:calendar_start_date] ? CONFIG[:calendar_start_date].to_date : "01-06-2015".to_date
  CALENDAR_NUM_YEARS_TO_SHOW = CONFIG[:calendar_num_years_to_show ] || 10
  CALENDAR_END_DATE = CALENDAR_START_DATE >> (12*CALENDAR_NUM_YEARS_TO_SHOW)

  API_ERRORS = [CCMeetup::ApiError, CCMeetup::Fetcher::ApiError]

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
    @show_update_slug = true
  end

  def update
#    authorize! :update, @event
    if @event.update_attributes(event_params)
      flash[:success] = "Your Event has been updated!"
      redirect_to @event
      #redirect_to edit_user_url(@user), :notice => "Username has been changed."
    else
      load_auth
      @show_update_slug = true
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

    def check_privacy
      logger.debug("**--**--**--**--++--**++------------------")
      logger.debug("In check_privacy")
      #Check if we need to require login, need to know if we can manage an event
      #or if current user needs to be a member of one of the participating groups
      #and check each condition once
      require_login = false
      check_can_manage_event = false
      check_is_group_member = false

      is_logged_in = signed_in?
      can_manage_event = false
      is_group_member = false
      curr_user_auth = nil
      @event_display_state = Event::VISIBLE_DISPLAY_STATE

      rsvp_states = [@event.rsvp_display_privacy, @event.rsvp_count_display_privacy]
      case @event.display_privacy
      when Event::PUBLIC_DISPLAY_PRIVACY
        require_login = check_can_manage_event = false
      when Event::PRIVATE_DISPLAY_PRIVACY
        require_login = check_can_manage_event = true
      when Event::REGISTERED_DISPLAY_PRIVACY
        require_login = true
      when Event::GROUP_MEMBERS_DISPLAY_PRIVACY
        require_login = true
        check_is_group_member = true
      else
        raise "Invalid display_privacy type #{@event.display_privacy}"
      end

      if (rsvp_states.include?(Event::PRIVATE_DISPLAY_PRIVACY))
        check_can_manage_event = true
      end
      if (rsvp_states.include?(Event::GROUP_MEMBERS_DISPLAY_PRIVACY))
        check_is_group_member = true
      end

      logger.debug("require_login = #{require_login}, check_can_manage_event = #{check_can_manage_event}, check_is_group_member = #{check_is_group_member}")

      #Check certian conditions if required
      if (require_login)
        si_mess = check_is_group_member ? "You need to be signed in through Meetup and be a member of a participating group to access this page." : "You need to be signed in to access this page. Please sign in."
        unless (signed_in_user(si_mess))
          return nil
        end
      end
      if (check_can_manage_event)
        can_manage_event = can? :manage, @event
      end
      if (check_is_group_member)
        if (is_logged_in)
          if (curr_user_auth = current_user.authentication_for_meetup)
            begin
              if (is_member_of_participating_event_groups?(curr_user_auth, @event))
                is_group_member = true
              else
                logger.debug("NOT A GROUP MEMBER!!!")
              end
            rescue *API_ERRORS => error
              #an error here means that there was a problem with this users auth
              logger.error("GOT ApiError: #{error.inspect}")
              #sign_out
              store_location
              redirect_to signin_url(rop: Authentication::MEETUP_PROVIDER_NAME), notice: "You must sign in through #{Authentication::MEETUP_PROVIDER_NAME} to access this page."
              return nil
            end
          end
        end
      end

      logger.debug("@event.display_privacy = #{@event.display_privacy},
                    @event.rsvp_display_privacy = #{@event.rsvp_display_privacy}
                    @event.rsvp_count_display_privacy = #{@event.rsvp_count_display_privacy}")
      logger.debug("is_logged_in = #{is_logged_in}, curr_user_auth = #{curr_user_auth}")

      logger.debug("can_manage_event = #{can_manage_event}, is_group_member = #{is_group_member}")
#  VISIBLE_DISPLAY_STATE = VALID_DISPLAY_STATES[0]
#  INVISIBLE_DISPLAY_STATE = VALID_DISPLAY_STATES[1]
#  HIDDEN_DISPLAY_STATE = VALID_DISPLAY_STATES[2]

#  NOT_LOGGED_IN_REASON = VALID_DISPLAY_STATES[0]
#  NOT_AUTHENTICATED_REASON = VALID_DISPLAY_STATES[1]
#  NOT_AUTHORIZED_REASON = VALID_DISPLAY_STATES[2]
#  NOT_LOGGED_IN_AND_AUTHENTICATED_REASON = VALID_DISPLAY_STATES[3]
#  NOT_MEMBER_REASON = VALID_DISPLAY_STATES[4]

      #check display privacy to see if user can view page. If require login, this
      #should have already been checked above
      case @event.display_privacy
      when Event::PRIVATE_DISPLAY_PRIVACY
        if (is_logged_in)
          if (can_manage_event)
            @event_display_state = Event::VISIBLE_DISPLAY_STATE
          else
            @event_display_state = Event::INVISIBLE_DISPLAY_STATE
            @event_no_display_reason = Event::NOT_AUTHORIZED_REASON
          end
        end
      when Event::GROUP_MEMBERS_DISPLAY_PRIVACY
        if (is_group_member)
          @event_display_state = Event::VISIBLE_DISPLAY_STATE
        else 
          @event_display_state = Event::INVISIBLE_DISPLAY_STATE
          @event_no_display_reason = Event::NOT_MEMBER_REASON
        end
      end
      rsvp_args = { is_logged_in: is_logged_in,
                    can_manage_event: can_manage_event,
                    is_group_member: is_group_member,
                    curr_user_auth: curr_user_auth }

      @rsvp_display_state, @rsvp_no_display_reason = get_rsvp_display_state(@event.rsvp_display_privacy, rsvp_args)
      @rsvp_count_display_state, @rsvp_count_no_display_reason = get_rsvp_display_state(@event.rsvp_count_display_privacy, rsvp_args)
      logger.debug("@rsvp_display_state = #{@rsvp_display_state}, @rsvp_count_display_state = #{@rsvp_count_display_state}")
      logger.debug("Is Group member = #{is_group_member}")
    end

    def get_rsvp_display_state(rsvp_display_privacy, args={})
      rsvp_display_state = nil
      rsvp_no_display_reason = nil
      is_logged_in = args[:is_logged_in]
      can_manage_event = args[:can_manage_event]
      is_group_member = args[:is_group_member]
      curr_user_auth = args[:curr_user_auth]

      logger.debug("--------------------------+++++++=====------")
      logger.debug("IN get_rsvp_display_state. rsvp_display_privacy = #{rsvp_display_privacy}")
      logger.debug("is_logged_in = #{is_logged_in}, can_manage_event = #{can_manage_event}")
      logger.debug("is_group_member = #{is_group_member}, curr_user_auth = #{curr_user_auth}")

      case rsvp_display_privacy
      when Event::PUBLIC_DISPLAY_PRIVACY
        rsvp_display_state = Event::VISIBLE_DISPLAY_STATE
      when Event::PRIVATE_DISPLAY_PRIVACY
        if (is_logged_in)
          if can_manage_event
            rsvp_display_state = Event::VISIBLE_DISPLAY_STATE
          else
            rsvp_display_state = Event::INVISIBLE_DISPLAY_STATE
            rsvp_no_display_reason = Event::NOT_AUTHORIZED_REASON
          end
        else
          rsvp_display_state = Event::HIDDEN_DISPLAY_STATE
          rsvp_no_display_reason = Event::NOT_LOGGED_IN_REASON 
        end
      when Event::REGISTERED_DISPLAY_PRIVACY
        if (is_logged_in)
          rsvp_display_state = Event::VISIBLE_DISPLAY_STATE
        else
          rsvp_display_state = Event::HIDDEN_DISPLAY_STATE
          rsvp_no_display_reason = Event::NOT_LOGGED_IN_REASON
        end
      when Event::GROUP_MEMBERS_DISPLAY_PRIVACY
        if (!is_logged_in)
          rsvp_display_state = Event::HIDDEN_DISPLAY_STATE
          rsvp_no_display_reason = Event::NOT_LOGGED_IN_AND_AUTHENTICATED_REASON
        elsif (curr_user_auth)
          logger.debug("**** GOT CURR_USER_AUTH")
          if (is_group_member)
            rsvp_display_state = Event::VISIBLE_DISPLAY_STATE
          else
            rsvp_display_state = Event::HIDDEN_DISPLAY_STATE
            rsvp_no_display_reason = Event::NOT_MEMBER_REASON
          end
        else
          logger.debug("** NO CURR_USER_AUTH!!")
          rsvp_display_state = Event::HIDDEN_DISPLAY_STATE
          rsvp_no_display_reason = Event::NOT_LOGGED_IN_AND_AUTHENTICATED_REASON
        end
      end
      logger.debug("About to return values [#{rsvp_display_state}, #{rsvp_no_display_reason}]")
      [rsvp_display_state, rsvp_no_display_reason]
    end

    def check_display_listing

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
      logger.debug("--==----==----==---===---==---==---=--====")
      logger.debug("Loaded event = #{@event}")
      @event.current_user = current_user
      @event.populate_excluded_members
      logger.debug("*** Loaded event = #{@event.inspect}")
    rescue ActiveRecord::RecordNotFound
      logger.debug("Record does not exist! rescuing")
      flash[:notice] = "This event does not exist!"
      redirect_to :action => 'index'
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
#        puts "event is remote!!!!"
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
             :remember_api_key, :display_privacy, :display_list, :title, :update_slug,
             :description, :start_date, :end_date, :location_id, :rsvp_display_privacy, 
             :rsvp_count_display_privacy, linked_events_attributes: [:url, :id],
             excluded_remote_members_attributes: [:id, :_destroy, :exclude_type, remote_member_attributes: [:id, :remote_source, :remote_member_id]],
             remote_event_api_attributes: [:api_key, :remember_api_key, 
              :remote_source,:id, 
              remote_event_api_sources_attributes: [:url, :is_primary_event, :id, :_destroy, :rank]])
    end
    
end