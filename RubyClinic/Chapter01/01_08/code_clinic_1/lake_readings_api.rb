#!/usr/bin/env ruby

require_relative('functions')

require 'sinatra' # gem install sinatra
require 'json'

# Accessible via http://localhost:4567

get '/' do
  text = "<h1>*** LAKE PEND OREILLE READINGS API ***</h1>"
  text << "<p>Calculates the mean and median of the wind speed, air temperature, and barometric pressure recorded at the Deep Moor station on Lake Pend Oreille for a given range of dates.</p>"
  text << "<p>Submit a request as '/readings?start=2014-01-01&end=2014-01-03'</p>"
  erb text
end

get '/readings' do

  start_date, end_date = url_params_for_date_range

  results = retrieve_and_calculate_results(start_date, end_date)

  content_type :json
  erb results.to_json
  
end

not_found do
  erb "Page not found"
end
