module ControllerFormatDate
  def self.included(controller)
    controller.send :helper_method, :sdatetime, :s_date_time, :word_date_time, :american_date, :american_date_time, :day_of_week, :month_name, :clock_time, :seconds_to_hours
  end

  def sdatetime(d)
     ret = nil
     begin
       ret = d.strftime('%m-%d-%Y %I:%M:S %p')
     rescue Exception => e
       logger.error("ERROR in sdatetime! #{e})")
     end
     ret
  end

  def s_date_time(d)
     convert_date(d, '%m-%d-%Y %I:%M %p')
  end

  def word_date_time(d)
     convert_date(d, '%A, %B %d, %Y %I:%M %p')
  end

  def american_date(d)
     convert_date(d, '%d/%m/%y')
  end

  def american_date_time(d)
     convert_date(d, '%d/%m/%y %I:%M %p')
  end

  def day_of_week(d)
     convert_date(d, '%A')
  end

  def month_name(d)
     convert_date(d, '%B')
  end

  def clock_time(d)
     convert_date(d, '%I:%M %p')
  end

  def seconds_to_hours(secs)
    Time.at(secs).gmtime.strftime('%R:%S')
  end

  private

  def convert_date(d, format)
     ret = nil
     begin
       ret = d.strftime(format)
     rescue Exception => e
       logger.error("ERROR in comvert_date (date = #{d}. format = #{format})! #{e})")
     end
     ret
  end

end
