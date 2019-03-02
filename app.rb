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
  csv_path       = params[:file][:tempfile].path
  data           = SmarterCSV.process(csv_path)

  @top_returns = Sort.new(portfolio_size, data).tops
  @last_returns = Sort.new(portfolio_size, data).lasts
  all_returns  = Sort.new(portfolio_size, data).all

  session[:top_returns] = @top_returns
  session[:last_returns] = @last_returns
  redirect '/download'
end

get '/download' do
  @tops = session[:top_returns]
  @lasts = session[:last_returns]
  content_type 'application/csv'
  attachment "sorted_top.csv"
  csv_string = CSV.generate do |csv|
    csv << ["Tops"]
    @tops.each do |hash_date|
      csv << hash_date.keys
      csv << hash_date.values
    end
    csv << ["Lasts"]
    @lasts.each do |hash_date|
      csv << hash_date.keys
      csv << hash_date.values
    end
  end
end