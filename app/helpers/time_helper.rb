module TimeHelper
  def format_secure_time(time)
    secure_time(time).strftime("%Y-%m-%d %H:%M %Z")
  end

  def secure_time(time)
    time_no_secs = time.beginning_of_minute

    rounded_minute = ((time_no_secs.min % 60) / 5.0).ceil * 5
    rounded_minute = 55 if rounded_minute > 50
    rounded_minute = rounded_minute.to_s.rjust(2, '0')

    time_no_secs.change(min: rounded_minute)
  end
end
