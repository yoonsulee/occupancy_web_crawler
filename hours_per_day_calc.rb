# The method takes the hour of operations and converts it into a 24-hour occupancy

class HoursPerDayCalc

  attr_reader :hours
  attr_reader :option

  def initialize(hours,option)
    @hours = hours
    @option = option

  end

  # options
  # 1: AM-PM                5: AM-AM (two days)           9: Open 24hrs (todo: need to add this option below)
  # 2: AM-AM (same day)     6: 6-9PM (assume both PM)
  # 3: PM-PM                7: 12-3PM, 4:30-9PM
  # 4: PM-AM                8: Closed

  def convert_24hrs

    $start = 0
    $end = 48         # 30min interval/use 24 for 1hr interval
    start_hr = 0
    finish_hr = 0

    if @option == 8
      @@hours_per_day = Array.new($end,0)
    else
      @@hours_per_day = []
      if @hours.include?(",")
        temp_time = @hours.split(",")
        time1 = temp_time[0].split("-")
        time2 = temp_time[1].split("-")
        # time1[0],time1[1],time2[0].delete(" "),time2[1]
      else
        time1 = @hours.split("-")
        #        puts time1[0],time1[1]                   # 4:30AM, 9PM
      end

      if @option == 1                          # time1 = 4:30am-9pm
        start = time1[0].split("AM")           # 4:30 or 4
        if start[0].include?(":")
          start_hr = (start[0].split(':')[0].to_i * 2) + 1   # 9=>4:30-5am
        else
          start_hr = start[0].to_i * 2                     # 8=>4-4:30am
        end

        finish = time1[1].split("PM")           # 9
        if finish[0].include?(":")
          finish_hr = (finish[0].split(':')[0].to_i + 12) * 2 + 1
        else
          finish_hr = (finish[0].to_i + 12) * 2         # both start_hr/finishr_hr are arrays!
        end

      elsif @option == 2                        # time1 = 4:30am-11am
        start = time1[0].split("AM")
        if start[0].include?(":")
          start_hr = (start[0].split(':')[0].to_i * 2) + 1
        else
          start_hr = start[0].to_i * 2
        end
        finish = time1[1].split("AM")           # 11
        if finish[0].include?(":")
          finish_hr = (finish[0].split(':')[0].to_i * 2) + 1
        else
          finish_hr = finish[0].to_i  * 2
        end

      elsif @option == 3                      # time1 = 1PM-5PM
        start = time1[0].split("PM")
        finish = time1[1].split("PM")
        if start[0].include?(":")
          start_hr = (start[0].split(':')[0].to_i + 12) * 2 + 1
        else
          start_hr = (start[0].to_i + 12) * 2
        end

        if finish[0].include?(":")
          finish_hr = (finish[0].split(':')[0].to_i + 12) * 2 + 1
        else
          finish_hr = (finish[0].to_i + 12) * 2
        end

      elsif @option == 4                     # time1 = 10PM-2AM
        start = time1[0].split("PM")
        finish = time1[1].split("AM")
        if start[0].include?(":")
          start_hr = (start[0].split(":")[0].to_i + 12) * 2 + 1
        else
          start_hr = (start[0].to_i + 12) * 2
        end

        if finish[0].include?(":")
          finish_hr = finish[0].split(":")[0].to_i * 2 + 1
        else
          finish_hr = finish[0].to_i * 2
        end

      elsif @option == 5                    # time1 = 10AM-1AM (next day)
        start = time1[0].split("AM")
        finish = time1[1].split("AM")
        if start[0].include?(":")
          start_hr = start[0].split(":")[0].to_i * 2 + 1
        else
          start_hr = start[0].to_i * 2
        end

        if finish[0].include?(":")
          finish_hr = finish[0].split(":")[0].to_i * 2 + 1
        else
          finish_hr = finish[0].to_i * 2
        end

      elsif @option == 6                    # time1 = 6-9PM
        start = time1[0]
        finish = time1[1].split("PM")
        if start[0].include?(":")
          start_hr = (start[0].split(':')[0].to_i + 12) * 2 + 1
        else
          start_hr = (start[0].to_i + 12) * 2
        end

        if finish[0].include?(":")
          finish_hr = (finish[0].split(':')[0].to_i + 12) * 2 + 1
        else
          finish_hr = (finish[0].to_i + 12) * 2
        end

      else                                    # @option = 7       time1 = 12-3PM, 4:30-9PM
        #puts time1[0],time1[1],time2[0].delete(" "),time2[1]   => 12, 3PM, 4:30, 9PM
        start1 = time1[0]
        finish1 = time1[1].split("PM" && "AM")
        start2 = time2[0].delete(" ")
        finish2 = time2[1].split("PM")

        if start1.include?(":")
          start1_hr = start1.split(":")[0].to_i * 2 + 1
        else
          start1_hr = start1.to_i * 2
        end
        if finish1[0].include?(":") && (time1[1].include?("PM"))
          finish1_hr = (finish1[0].split(":")[0].to_i + 12) * 2 + 1
        elsif finish1[0].include?(":") && (time1[1].include?("AM"))
          finish1_hr = finish1[0].split(":")[0].to_i * 2 + 1
        elsif time1[1].include?("PM")
          finish1_hr = (finish1[0].to_i + 12) * 2
        else
          finish1_hr = (finish1[0].to_i) * 2
        end
        if start2.include?(":")
          start2_hr = (start2.split(":")[0].to_i + 12) * 2 + 1
        else
          start2_hr = (start2.to_i + 12) * 2
        end
        if finish2[0].include?(":")
          finish2_hr = (finish2[0].split(":")[0].to_i + 12) * 2 + 1
        else
          finish2_hr = (finish2[0].to_i + 12) * 2
        end
 #       puts start1_hr, start2_hr, finish1_hr, finish2_hr
      end

      # use start_hr and finish_hr to populate a daily occupancy trend [0,1]
      begin
        if @option == 4 || @option == 5
          if ($start < finish_hr) || ($start > start_hr - 1)
            @@hours_per_day[$start] = 1
          else
            @@hours_per_day[$start] = 0
          end
        elsif @option == 7
          if ($start < start1_hr) || ($start > finish2_hr)
            @@hours_per_day[$start] = 0
          elsif ($start < start2_hr) && ($start > finish1_hr - 1)
            @@hours_per_day[$start] = 0
          else
            @@hours_per_day[$start] = 1
          end
        else
          if ($start < start_hr) || ($start > finish_hr - 1)
            @@hours_per_day[$start] = 0
          else
            @@hours_per_day[$start] = 1
          end
        end
        $start += 1

      end while $start < $end

      return @@hours_per_day                      # an array of 48 30-min intervals
    end
  end


end

#test = HoursPerDayCalc.new("10:30-2PM, 4:30-9:30PM",7)
#test.convert_24hrs
