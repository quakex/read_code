require 'readline'
require 'date'
require 'open-uri'

# The earliest date for which there is consistent data
DATA_START_DATE = '2006-09-20'

# We want to be kind to the remote server. This is the maximum number 
# of days that can be retrieved. Remember for each day, we will 
# make 3 queries, one for each reading type. Keep this value low.
MAX_DAYS = 7

# The supported reading types as a hash.
# Each key is the name used by the remote server to locate the data.
# Each value is a plain text label for that data.
READING_TYPES = {
  "Wind_Speed" => "Wind Speed", 
  "Air_Temp" => "Air Temp", 
  "Barometric_Press" => "Pressure"
}

### User Input ###

# Ask the user (via the command line) to provide valid start 
# and end dates.
def query_user_for_date_range
  start_date = nil
  end_date = nil

  until start_date && end_date
    puts "\nFirst, we need a start date."
    start_date = query_user_for_date

    puts "\nNext, we need an end date."
    end_date = query_user_for_date
  
    if !date_range_valid?(start_date, end_date)
      puts "Let's try again."
      start_date = end_date = nil
    end
    
  end
  
  return start_date, end_date
end

# Ask the user (via the command line) for a single valid date. 
# Used for both start and end dates.
def query_user_for_date
  date = nil
  until date.is_a? Date
    prompt = "Please enter a date as YYYY-MM-DD: "
    response = Readline.readline(prompt, true)
    
    # We have the option to quit at any time.
    exit if ['quit', 'exit', 'q', 'x'].include?(response)

    begin
      date = Date.parse(response)
    rescue ArgumentError
      puts "\nInvalid date format."
    end
    
    date = nil unless date_valid?(date)
    
  end
  return date
end

# Test if a single date is valid
def date_valid?(date)
  valid_dates = Date.parse(DATA_START_DATE)..Date.today
  if valid_dates.cover?(date)
    return true
  else
    puts "\nDate must be after #{DATA_START_DATE} and before today."
    return false
  end
end

# Test if a range of dates is valid
def date_range_valid?(start_date, end_date)
  if start_date > end_date
    puts "\nStart date must be before end date."
    return false
  elsif start_date + MAX_DAYS < end_date
    puts "\nNo more than #{MAX_DAYS} days. Be kind to the remote server!"
    return false
  end
  return true
end


### Retrieve remote data ###

# Retrieves readings for a particular reading type for a range 
# of dates from the remote server as an array of floating point 
# values.
def get_readings_from_remote_for_dates(type, start_date, end_date)
  readings = []
  start_date.upto(end_date) do |date|
    readings += get_readings_from_remote(type, date)
  end
  return readings
end

# Retrieves readings for a particular reading type for a particular 
# date from the remote server as an array of floating point values.
def get_readings_from_remote(type, date)
  raise "Invalid Reading Type" unless READING_TYPES.keys.include?(type)
  
  # read the remote file, split readings into an array
  base_url = "http://lpo.dt.navy.mil/data/DM"
  url = "#{base_url}/#{date.year}/#{date.strftime("%Y_%m_%d")}/#{type}"
  puts "Retrieving: #{url}"
  data = open(url).readlines

  # Extract the reading from each line
  # "2014_01_01 00:02:57   7.6\r\n" becomes 7.6
  readings = data.map do |line|
    line_items = line.chomp.split(" ")
    reading = line_items[2].to_f
  end
  return readings
end


### Data Calculations ###

# Calculates the mean (average) of an array of numbers.
def mean(array)
  total = array.inject(0) {|sum, x| sum += x }
  # Use to_f or you will get an integer result
  return total.to_f / array.length
end

# Calculates the median (middle) of an array of numbers.
def median(array)
  array.sort!
  length = array.length
  if length % 2 == 1
    # odd length, return the middle number
    return array[length/2]
  else
    # even length, average the two middle numbers
    item1 = array[length/2 - 1]
    item2 = array[length/2]
    return mean([item1, item2])
  end
end

# Given a start date and end date, will go through all supported
# READING_TYPES, retrieve values from the remote server, 
# and calculate the mean and average of the values. 
# Results are returned as a Hash.
def retrieve_and_calculate_results(start_date, end_date)
  results = {}
  READING_TYPES.each do |type,label|
    readings = get_readings_from_remote_for_dates(type, start_date, end_date)
    results[label] = {
      :mean => mean(readings),
      :median => median(readings)
    }
  end
  return results
end


### Output ###

# Output the results hash formatted as a table of data 
# to the console.
def output_results_table(results={})
  puts
  puts "----------------------------------------"
  puts "| Type       | Mean       | Median     |"
  puts "----------------------------------------"
  results.each do |label, hash|
    print "| " + label.ljust(10) + " | "
    print sprintf("%.6f", hash[:mean]).rjust(10) + " | "
    puts sprintf("%.6f", hash[:median]).rjust(10) + " |"
  end
  puts "----------------------------------------"
  puts
end


### API methods ###

# Use the URL parameters for finding valid start and end dates.
def url_params_for_date_range
  begin
    start_date = Date.parse(params[:start])
    end_date = Date.parse(params[:end])
  rescue ArgumentError
    halt "Invalid date format."
  end

  # call our validations
  if !date_valid?(start_date)
    halt "Start date must be after #{DATA_START_DATE} and before today."
  elsif !date_valid?(end_date)
    halt "End date must be after #{DATA_START_DATE} and before today."
  elsif !date_range_valid?(start_date, end_date)
    halt "Invalid date range."
  end

  return start_date, end_date
end
