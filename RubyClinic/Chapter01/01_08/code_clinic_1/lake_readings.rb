#!/usr/bin/env ruby

require_relative('functions')

puts "\n*** LAKE PEND OREILLE READINGS *** "
puts "Calculates the mean and median of the wind speed, air temperature,"
puts "and barometric pressure recorded at the Deep Moor station"
puts "on Lake Pend Oreille for a given range of dates."

start_date, end_date = query_user_for_date_range

results = retrieve_and_calculate_results(start_date, end_date)

# puts results.inspect
# {"Wind Speed" => {:mean => 3.8900432900432897, :median => 2.8}, 
#  "Air Temp"   => {:mean => 36.18095238095237, :median => 36.3}, 
#  "Pressure"   => {:mean => 28.2649350649351, :median => 28.3} }

output_results_table(results)
