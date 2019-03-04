require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require "smarter_csv"
require "csv"
require "sinatra/flash"
require_relative "models/sort"
require_relative "models/average"
require_relative "models/generate_csv"
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

  case params[:report]
  when "option1"
    session[:top_returns]  = Sort.new(portfolio_size, data).tops
    session[:last_returns] = Sort.new(portfolio_size, data).lasts
    redirect '/download/sorted'
  when "option2"
    session[:top_returns]  = Sort.new(portfolio_size, data).top_portfolio_returns
    session[:last_returns] = Sort.new(portfolio_size, data).last_portfolio_returns
    redirect '/download/sorted'
  when "option3"
    sorted_top_returns     = Sort.new(portfolio_size, data).top_portfolio_returns
    sorted_last_returns    = Sort.new(portfolio_size, data).last_portfolio_returns
    session[:top_returns]  = Average.new(portfolio_size, sorted_top_returns).average_return
    session[:last_returns] = Average.new(portfolio_size, sorted_last_returns).average_return
    redirect '/download/average'
  else
    redirect '/'
  end
end

get '/download/sorted' do
  content_type 'application/csv'
  attachment "sorted_returns.csv"
  csv_string = GenerateCsv.new(session[:top_returns], session[:last_returns]).sorted_with_tops_and_lasts
end

get '/download/average' do
  content_type 'application/csv'
  attachment "average_returns.csv"
  csv_string = GenerateCsv.new(session[:top_returns], session[:last_returns]).average_with_tops_and_lasts
end
