require 'sinatra'
require 'sinatra/activerecord'
require_relative "models/sort"
require_relative "models/average"
require_relative "models/generate_csv"
require_relative './config/environments'
require "sinatra/reloader" if development?
require "pry-byebug"
require "smarter_csv"
require "csv"
require "sinatra/flash"

get '/' do
  erb :index
end

post '/upload' do
  if params[:portfolio_size].nil? || params[:file].nil? || !params[:file][:filename].match?('.+(\.csv)$') || params[:min_volatility].nil? || params[:max_volatility].nil?
    flash[:warning] = "Please uplaod a csv file and fill in the portfolio size"
    redirect '/'
  end

  Sort.destroy_all

  portfolio_size            = params[:portfolio_size].to_i
  min_volatility            = params[:min_volatility].to_f
  max_volatility            = params[:max_volatility].to_f
  data                      = SmarterCSV.process(params[:file][:tempfile].path)
  @sort_instance            = Sort.new(size: portfolio_size, data: data, min_volatility: min_volatility, max_volatility: max_volatility)
  tickers                   = CSV.read(params[:file][:tempfile].path)[0].drop(1).map { |ticker| ticker.downcase.to_sym }
  @sort_instance.returns    = @sort_instance.list_of_stocks(tickers)
  @sort_instance.volatility = @sort_instance.stock_volatility

  @sort_instance.all        = @sort_instance.sort_all
  @sort_instance.save

  case params[:report]
  when "option1"
    redirect to "/download/sorted/#{@sort_instance.id}"
  when "option2"
    redirect "/download/portfolio-sorted/#{@sort_instance.id}"
  when "option3"
    redirect "/download/average-returns/#{@sort_instance.id}"
  else
    redirect '/'
  end
end

get "/download/sorted/:id" do
  instance = Sort.find(params[:id])
  tops     = instance.tops
  lasts    = instance.lasts
  content_type 'application/csv'
  attachment "sorted_returns.csv"
  csv_string = GenerateCsv.new(tops, lasts).sorted_with_tops_and_lasts
end

get "/download/portfolio-sorted/:id" do
  instance_sort = Sort.find(params[:id])
  tops  = instance_sort.top_portfolio_returns
  lasts = instance_sort.last_portfolio_returns
  content_type 'application/csv'
  attachment "sorted_returns.csv"
  csv_string = GenerateCsv.new(tops, lasts).sorted_with_tops_and_lasts
end

get "/download/average-returns/:id" do
  instance_sort = Sort.find(params[:id])
  tops         = instance_sort.top_portfolio_returns
  lasts        = instance_sort.last_portfolio_returns
  size         = instance_sort.size
  top_returns  = Average.new(size, tops).average_return
  last_returns = Average.new(size, lasts).average_return
  content_type 'application/csv'
  attachment "average_returns.csv"
  csv_string = GenerateCsv.new(top_returns, last_returns).average_with_tops_and_lasts
end