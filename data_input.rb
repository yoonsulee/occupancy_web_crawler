# The method takes outside data source and populates the input for spider.rb
require 'spreadsheet'
require 'json'
require 'CSV'

class Fixnum
  def num_digits
    Math.log10(self).to_i + 1
  end
end

class DataInput

  def initialize(path,options,tab)
    @path = path
    @options = options
    @tab = tab
    # options
    # 1-CSV, 2-xlsx, 3-JSON, 4-txt, etc...

  end

  def read_data
    table = CSV.read("#{@path}")
#    puts table[0]                 # headers
    data_matrix = Hash.new{ |v,k| v[k] = Hash.new()}
    data_table = {}
    ################## this part needs to be customized to your own set of data ######################################
    i = 0                                     # this will need to be struct_id or building id
    CSV.foreach("#{@path}") do |row|
      data_table[:index] = row[0].to_i              # :index=0 will most likely be the header

      # row[13] is zipcodes. See if it is missing '0' and adds to make it a full 5-digit zip
      if i >= 1
        init_zip = row[13].to_i                     # row[?]: zipcodes will depend on the data provided by users
        full_zip = zip_correct(init_zip)
      end
      data_table[:address] = row[4]+row[5]+row[6]+row[7]+row[8]+row[9]+row[10]+" "+row[11]+" "+row[12]+" "+"#{full_zip}"
      data_table[:zip] = full_zip
      data_table[:name] = row[2]
      data_table[:lat] = row[16]
      data_table[:long] = row[17]
      data_table[:sqft] = row[15]             # sqft of the business/property
      data_table[:cde1] = row[19]             # primary business description
      data_table[:cde2] = row[21]             # secondary business description
      data_table[:naics] = row[23]            # NAICS description
      data_table[:bus_stat] = row[24]         # single location, branch, HQ, or subsidiary
      data_table[:ind_firm] = row[25]         # individual or firm
      data_matrix["#{i}"].merge!(data_table)

      i += 1
    end
#    puts data_matrix['2']                  # query the 2nd object of the hash
#    puts data_matrix['2'][:address]        # query individual objects in the 2nd object
    return data_matrix
  end

  def read_data_json(data_hash)
    return data_hash.to_json      # creates JSON
  end

  def zip_correct(zip)
    if zip.num_digits == 4        # catch MA zipcodes that start with '0'
      zip = "0"+zip.to_s
    end
    return zip
  end


end

# test

#ciap_path = "/Users/yoonsulee/desktop/Hours_Web/ciap_naics_20.csv"
#base_data = DataInput.new(ciap_path,1,"SamplePerType")
#data_hash = base_data.read_data
##puts base_data.read_data_json(data_hash)
##jhash = base_data.read_data_json(data_hash)
##puts data_hash["40"][:address]                # individual values
#puts data_hash["19"]
#=> {:index=>50, :address=>"251  NEW KARNERRD   ALBANY NY 12205", :name=>"HOUSE TALK                    ", :long=>"40,000 - 99,999", :lat=>"42.722216"}
#puts data_hash.keys      # all the indexes
#data_hash.each_key{|key| puts data_hash["#{key}"][:naics]}                # all the naics descriptions