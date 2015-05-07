module ApplicationHelper

  DEFAULT_NO_ANSWER = "No answer yet"

	#returns the full title on a per-page basis
	def full_title(page_title)
		base_title = CONFIG[:title] || "Ruby on Rails Template"
		if page_title.empty?
			base_title
		else
			"#{base_title} | #{page_title}"
		end
	end

  #returns the Display Name of the application
  def app_display_name
    CONFIG[:display_name] || "Multigroup Events" 
  end

	#return class name for flash message based on type
  def bootstrap_class_for flash_type
    case flash_type
      when "success"
        "alert-success" # Green
      when "error"
        "alert-danger" # Red
      when "alert"
        "alert-warning" # Yellow
      when "notice"
        "alert-info" # Blue
      else
        flash_type.to_s
    end
  end

  def display_no_answer(msg=DEFAULT_NO_ANSWER)
    content_tag(:span, msg, class: "no-answer")
  end

  def show_answer(answer)
    answer.blank? ? display_no_answer : answer
  end

  def edit_object_link(obj, name=nil)
    name ||= obj.class.name.humanize
    label = "Edit"
    if obj.new_record?
      label = "Create"
    end
    link_to "#{label} #{name}", edit_polymorphic_path(obj)
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def add_active_if_current(args = {})
    current_page?(args) ? " class=\"active\" ".html_safe : ""
  end

end
