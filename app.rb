require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require "smarter_csv"
require_relative "models/sort"
require "csv"
require 'sinatra/flash'
enable :sessions

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
  erb :index
end

post '/upload' do
  if params[:portfolio_size] === "" || params[:file].nil?
    flash[:warning] = "Please uplaod a csv file and fill in the portfolio size"
    redirect '/'
  end

  portfolio_size = params[:portfolio_size].to_i
  data           = SmarterCSV.process(params[:file][:tempfile].path)

  if    params[:report] == "option1"
    top_returns  = Sort.new(portfolio_size, data).tops
    last_returns = Sort.new(portfolio_size, data).lasts
  elsif params[:report] == "option2"
    top_returns  = Sort.new(portfolio_size, data).top_portfolio_returns
    last_returns = Sort.new(portfolio_size, data).last_portfolio_returns
  end

  session[:top_returns]  = top_returns
  session[:last_returns] = last_returns
  redirect '/download'
end

get '/download' do
  tops  = session[:top_returns]
  lasts = session[:last_returns]

  content_type 'application/csv'
  attachment "sorted_top.csv"
  csv_string = CSV.generate do |csv|
    csv << ["Tops"]
    tops.each do |single_date_returns|
      csv << single_date_returns.keys
      csv << single_date_returns.values
    end
    csv << ["Lasts"]
    lasts.each do |single_date_returns|
      csv << single_date_returns.keys
      csv << single_date_returns.values
    end
  end
end
