class EventsController < ApplicationController
  before_filter :signed_in_user, :except => [:index, :index_tab, :show]
  before_filter :load_event, :only => [:show, :rsvp_print, :edit, :update, :reload_api, :destroy]
  layout "minimal", only: [:rsvp_print]

  class InvalidEventTypeError  < StandardError; end

  def index
    @events = Event.listed.upcoming
   #render :index_tab, tab: 'upcoming'
  end

  def index_tab
    tab = params[:tab]
    unless tab
      display_error("No Tab Specified")
      return
    end

    case tab.downcase
    when Event::EVENT_TAB_UPCOMING
      @events = Event.listed.upcoming
    when Event::EVENT_TAB_PAST
      @events = Event.listed.past
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
   # @event = Event.friendly.find(params[:id], :include=>:linked_events)
#    @event = Event.friendly.find(params[:id])
  end

  def rsvp_print
    authorize! :manage, @event
#    @event = Event.friendly.find(params[:id])
  end

  def new
#    flash.delete(:error) if flash[:error]
    authorize! :create, Event
    begin
      @event = new_event(params[:type])
      @api_keys = get_api_keys
    rescue InvalidEventTypeError => e
      flash.now[:error] = e.message
      @event = new_event()
    end
  end

  def create
    puts "event params = #{event_params}"
    authorize! :create, Event
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if @event.save
      flash[:success] = "Your Event has been created!"
      redirect_to @event
    else
      @api_keys = get_api_keys
      render 'new'
    end
  end

  def edit
    authorize! :edit, @event
#    @event = Event.friendly.find(params[:id])
    @user = current_user
    @api_keys = get_api_keys
  end

  def update
    authorize! :update, @event
  #  @event = Event.friendly.find(params[:id])
    @user = current_user

#    @user = User.find_by_id!(params[:id])
    if @event.update_attributes(event_params)
      flash[:success] = "Your Event has been updated!"
      redirect_to @event
      #redirect_to edit_user_url(@user), :notice => "Username has been changed."
    else
      @api_keys = get_api_keys
      render :edit
    end
  end

  def reload_api
    authorize! :update, @event
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
    def load_event
      @event = Event.friendly.find(params[:id])
      logger.debug("*** Loaded event = #{@event.inspect}")
    end

    def new_event(type=nil)
      puts "in new_event. type = '#{type}'"
      ret = nil
      if (type)
        if (Event.valid_event_type?(type))
          ret = type.constantize.new
          ret.type = type
          p "new event = #{ret}, type = #{type}"
        else
          puts "About to raise InvalidEventTypeError"
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
        puts("api_source = #{api_source.inspect}")
        ret.build_remote_event_api(remote_source: RemoteEvent::MEETUP_NAME)
        #ret.remote_event_api.remote_event_api_sources << RemoteEventApiSource.new(is_primary_event: true, rank: 1)
        ret.remote_event_api.remote_event_api_sources << api_source
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

    def event_params
      params.require(:event).permit(:type, :remote_api_key, :display_listing, 
             :remember_api_key, :display_privacy, :display_list, :title, 
             :description, :start_date, :end_date, :location_id,
             linked_events_attributes: [:url, :id],
             remote_event_api_attributes: [:api_key, :remember_api_key, 
              :remote_source,:id, 
              remote_event_api_sources_attributes: [:url, :is_primary_event, :id, :_destroy, :rank]])
    end
    
end