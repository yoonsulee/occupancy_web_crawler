
class Case
  # include methods to describe details about the scraped hour of operation

#  $hours_all = {}    #global variable that records all the hours of operation data
  attr_reader :hours

  def initialize(hours)
    @hours = hours
  end

  def calc_option
    time1 = @hours.split("–")
#    puts time1[0], time1[1]     #== 6:30AM and 11PM
#    puts time1

    if time1[0].include?('AM') && time1[1].include?('PM')
      option = 1
    elsif time1.include?("Closed")
      option = 8
    elsif time1.include?("Open 24")
      option = 9
    elsif time1[0].include?('AM') && time1[1].include?('AM')
      time2 = time1[1].split('AM')[0].split(':')[0]  # end hour only read-in as "String"
      time3 = time1[0].split('AM')[0].split(':')[0]  # start hour only
      if (time2.to_i > time3.to_i) && (time2.to_i < 12)
        option = 2                                      # e.g., 8AM-11AM (morning only)
      else
        option = 5                                      # e.g., 9AM-2AM (until next morning)
      end
    elsif time1[0].include?('PM') && time1[1].include?('PM')
        option = 3
    elsif time1[1].include?('PM')     # e.g., 5-11PM then assume start time=PM
      option = 6
    elsif time1.include?(',')         # e.g., 12-3PM, 4:30-9PM then split with a ',' and assume start time is PM
      option = 7
    else option = 4   # PM-AM
    end

    return option
  end #end of : def calc_option


end #end of: class Case


#test
#option = Case.new('Closed')
#option = Case.new('2–5PM')
#x = option.calc_option
#puts x
