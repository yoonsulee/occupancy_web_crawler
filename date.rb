require 'date'

class Date
  def dayname
    DAYNAMES[self.wday]
  end

  def abbr_dayname
    ABBR_DAYNAMES[self.wday]
  end
end

#check
#today = Date.today
#puts today.dayname        #-> Friday
#puts today.abbr_dayname   #-> Fri