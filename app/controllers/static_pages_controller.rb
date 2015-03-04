class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def error
  end

 # caches_page :event_js

  def event_js
    valid = %w(event  event_list  no_rsvp  rsvp_count  rsvp_list  yes_rsvp)
    if valid.include?(params[:page])
      #render layout: false, handlers: :, content_type: 'text/plain', file: File.join(Rails.root, 'app/views/events/templates', params[:page])
      render layout: false, plain: File.read(File.join(Rails.root, 'app/views/events/templates', params[:page]))
    else
      render :file   => File.join(Rails.root, 'public', '404.html'), 
             :status => 404
    end
  end
end
