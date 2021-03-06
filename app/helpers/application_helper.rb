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
  
  def link_to_add_fields(name, f, association, options = {})
    last_rank = f.object.try("last_rank") || 0
    last_rank_input = options[:last_rank_input]
    new_rank_marker = options[:new_rank_marker]
    nested_association = options[:nested_association]
    a_id = options[:id]
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    p "==@@++@@++ IN LINK_TO_ADD_FIELDS. nested_association: #{nested_association}"
    if (nested_association)
      p "==@@== Has nested_association: #{nested_association}"
      #Build nested association
      build_command = "build_#{nested_association.to_s}".to_sym
      p "build_command = #{build_command}"
      if (new_object.respond_to? build_command)
        p "Building #{build_command}"
        new_object.send(build_command)
      end
    end
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder, loc_rank: last_rank+1)
    end
    data_h = {id: id, fields: fields.gsub("\n", "")}
    if last_rank_input
      data_h[:last_rank_input] = last_rank_input
    end
    if new_rank_marker
      data_h[:new_rank_marker] = new_rank_marker
    end
    link_options = { class: "add_fields", data: data_h }
    p "**__**__ ID = #{id}"
    if (a_id)
      link_options[:id] = a_id
    end
    p "**_**__** link_options = #{link_options.inspect}"
#    link_to(name, '#', class: "add_fields", data: data_h)
    link_to(name, '#', link_options)
  end

  def add_active_if_current(args = {})
    current_page?(args) ? " class=\"active\" ".html_safe : ""
  end

  def display_start_and_end_date(start_date, end_date = nil, minimal=false)
    ret = minimal ? clock_time(start_date) : word_date_time(start_date)
    if (end_date)
      ret += " to #{clock_time(end_date)}"
    end
    ret
  end
  
  def calendar(date = Date.today, &block)
    Calendar.new(self, date, block).table
  end
end
