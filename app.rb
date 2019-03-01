require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require "smarter_csv"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  erb :index
end

post '/upload' do
  number_of_last = params[:portfolio_size].to_i
  number_of_top = params[:portfolio_size].to_i

  csv_path = params[:file][:tempfile].path
  data = SmarterCSV.process(csv_path)

  sorted_data = []
  data.each do |date_hash|
    on_recurrence_returns = date_hash.reject { |k, v| k === :date }
    sorted_returns = on_recurrence_returns.sort_by(&:last).to_h
    sorted_returns[:date] = date_hash[:date]
    sorted_data << sorted_returns
  end

  last_selected = []
  sorted_data.each do |sorted_hash|
    on_recurrence_lasts = sorted_hash.first(number_of_last).to_h
    on_recurrence_lasts[:date] = sorted_hash[:date]
    last_selected << on_recurrence_lasts
  end

  top_selected = []
  sorted_data.each do |sorted_hash|
    first = sorted_hash.length - 1
    number_to_first = first - number_of_top
    on_recurrence_tops = {}
    sorted_hash.keys[number_to_first...first].each do |key|
      on_recurrence_tops[key] = sorted_hash[key]
    end
    on_recurrence_tops[:date] = sorted_hash[:date]
    top_selected << on_recurrence_tops
  end

  redirect '/'
end
