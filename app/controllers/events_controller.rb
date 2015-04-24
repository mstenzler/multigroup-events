class EventsController < ApplicationController
  before_filter :signed_in_user, :except => [:index, :show]

  class InvalidEventTypeError  < StandardError; end

  def index
    @events = Event.all
  end

  def show
   # @event = Event.friendly.find(params[:id], :include=>:linked_events)
    @event = Event.friendly.find(params[:id])
  end

  def new
#    flash.delete(:error) if flash[:error]
    begin
      @event = new_event(params[:type])
    rescue InvalidEventTypeError => e
      flash.now[:error] = e.message
      @event = new_event()
    end
  end

  def create
    puts "event params = #{event_params}"
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if @event.save
      flash[:success] = "Your Event has been created!"
      redirect_to @event
    else
      render 'new'
    end
  end

  def edit
#    @user = User.find_by_id!(params[:id])
    @event = Event.friendly.find(params[:id])
    @user = current_user
  end

  def update
    @event = Event.friendly.find(params[:id])
    @user = current_user

#    @user = User.find_by_id!(params[:id])
    if @event.update_attributes(event_params)
      flash[:success] = "Your Event has been updated!"
      redirect_to @event
      #redirect_to edit_user_url(@user), :notice => "Username has been changed."
    else
      render :edit
    end
  end

  private

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
      ret.linked_events << LinkedEvent.new
      ret.user_id = current_user.id
      ret
    end

    def event_params
      params.require(:event).permit(:type, :remote_api_key, :remember_api_key, :display_privacy, :display_list, :title, :description, :start_date, :end_date, :location_id, linked_events_attributes: [:url])
    end
    
end