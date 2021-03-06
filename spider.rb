require 'mechanize'
require './date.rb'
require './case.rb'
require './data_input.rb'

class Spider

  @@search_array = []
  @@options = 0

  def initialize(search_engine)
    @search_engine = search_engine
  end

  def scrape_single(key_word,day)
    #setup agent
    agent = Mechanize.new{ |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    agent.ignore_bad_chunking = true

    #page setup
    @search_engine = 'http://google.com'    #just use google for now
    agent.get(@search_engine) do |page|
      @@search_result = page.form('f') do |search|
        search.q = key_word
      end.submit

      @@search_result.links.each do |link|
        @@search_array << link.text             # search_array is an array of the scraped text
      end

      @@hours = {}
      if @@search_result.css('div._XWk')[0]
        @result_day = @@search_result.css('div._XWk')[0].text
      else
        @result_day = nil
      end
    end

#    today = Date.today
#    day_of_week_actual = today.dayname
#    hoo_hash = {}
    hoo_hash = Hash.new{ |v,k| v[k] = Hash.new()}
    if @result_day
      @@hours["#{day}"] = @result_day
      hoo_hash.merge!(@@hours)
#      @@options = Case.new("#{@result_day}").calc_option     # todo: need to add this somewhere else
#      hoo_hash["#{@@options}"] = @@hours
#    else
#      puts "No hour data available"
    end


    return hoo_hash

  end

  def scrape_multiple(path)
    base_hash = DataInput.new(path,1,"SamplePerType").read_data   # 1-CSV, "SamplePerType"-only for xlsx files
#    return base_hash["50"]
    #=> {:index=>50, :address=>"251  NEW KARNERRD   ALBANY NY 12205", :name=>"HOUSE TALK", :long=>"40,000 - 99,999", :lat=>"42.722216"}
    day_of_week = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']
    data_matrix = Hash.new{ |v,k| v[k] = Hash.new()}
    key_word = {}
    base_hash.each do |key, value|

      zip_key = base_hash["#{key}"][:zip]
      busi_name_key = base_hash["#{key}"][:name]
      index_key = base_hash["#{key}"][:index]
      key_word = "#{busi_name_key} + " " + #{zip_key}"

      # run scrape using the above key word for each day of the week
      day_of_week.each do |days|
        key_word_new = key_word + "  #{days} hours"
        daily_hoo = scrape_single(key_word_new,days)
        popular = occup_hours(@@search_result)
        data_matrix["#{index_key}"].merge!(popular)
        data_matrix["#{index_key}"].merge!(daily_hoo)
      end
      puts index_key
    end

    # check to see how many hours of operations were scraped off of the entire building stock input
    empty_count = 0
    empty_hours = 0
    data_matrix.each do |k,v|
      if data_matrix["#{k}"]["monday"].nil? && data_matrix["#{k}"][""].empty?
        empty_count += 1
      else
        empty_count += 0
        if data_matrix["#{k}"][""]
          empty_hours += 1
        end
      end
    end
#    puts "Out of #{data_matrix.count()} buildings, #{empty_count} were empty and #{data_matrix.count() - empty_count} were created."
#    puts "Total of #{data_matrix.count() - empty_count - empty_hours} daily hours accounted for."
    temp = {}
    total_hoo = data_matrix.count() - empty_count
    total_hours = data_matrix.count() - empty_count - empty_hours
    temp["hoo"] = total_hoo
    temp["hours"] = total_hours
    data_matrix["stats"].merge!(temp)

    return data_matrix
  end

  def occup_hours(page)
    day_selected = page.css('div._opj li.lubh-sel').text
      if day_selected
        hours_hash = {}
        hour_array = []
        page.css('div#rhs div._qpj div.lubh-bar').each do |time|
          popular_time = time.to_s.split(":")[1].split("px")[0]            # only prints out popular times for the exact day searched
          hour_array.push(popular_time)
        end
        hours_hash["#{day_selected}"] = hour_array
        return hours_hash
      end
  end

  def save_to_json(data_hash)
    json_path = "/Users/yoonsulee/desktop/Hours_Web/results.json"
    File.open(json_path,"w") do |f|
      f.write(data_hash.to_json)
    end
  end


end #end of :class Spider

############################################################################
#to test in command line:
#                        ruby -r "./spider.rb" -e "Spider.scrape_single"

#key_word = 'VANDERVORT GROUP LLC 12210 monday hours'
key_word = 'seven stars bakery monday hours'
#temp = Spider.new('a').scrape_single(key_word,'saturday')
#puts temp
path = "/Users/yoonsulee/desktop/Hours_Web/ciap1.csv"
temp2 = Spider.new('b').scrape_multiple(path)
puts temp2
Spider.new('c').save_to_json(temp2)
