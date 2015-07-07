module FormatDate

  FUNCTIONS = :sdatetime, :s_date_time, :word_date_time, 
              :word_date, :american_date, :american_date_time, 
              :day_of_week, :month_name, :clock_time, :month_day_year,
              :month_day_full_year, :short_word_date, :seconds_to_hours

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
     convert_date(d, '%m-%d-%Y %l:%M %p')
  end

  def word_date_time(d)
     convert_date(d, '%A, %B %d, %Y %l:%M %p')
  end

  def word_date(d)
     convert_date(d, '%A, %B %d, %Y')
  end

  def short_word_date(d, options={})
    wday = options[:full_weekday] ? '%A' : '%a'
    month = options[:full_month] ? '%B' : '%b'
    year = options[:year] ? ', %Y' : ''
    convert_date(d, "#{wday}, #{month} %d#{year}")
  end

  def american_date(d)
     convert_date(d, '%d/%m/%y')
  end

  def american_date_time(d)
     convert_date(d, '%d/%m/%y %l:%M %p')
  end

  def day_of_week(d)
     convert_date(d, '%A')
  end

  def month_name(d)
     convert_date(d, '%B')
  end

  def clock_time(d)
     convert_date(d, '%l:%M %p')
  end

  def month_day_year(d)
    convert_date(d, '%m-%d-%y')
  end

  def month_day_full_year(d)
    convert_date(d, '%m-%d-%Y')
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
