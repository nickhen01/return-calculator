class Sort < ActiveRecord::Base
  serialize :data, Array
  serialize :all, Array
  serialize :volatility, Hash
  serialize :returns, Array

  def standard_deviation(array)
    sum = 0
    array.each do |stock_return|
      sum += stock_return
    end

    mean = sum / array.length

    array.map! do |stock_return|
      (stock_return - mean) * (stock_return - mean)
    end

    sum = 0
    array.each do |stock_return|
      sum += stock_return
    end

    square_mean = sum / array.length

    return Math.sqrt(square_mean)
  end

  def list_of_stocks(tickers)
    stock_list = []
    tickers.each do |ticker|
      stock_hash = {}
      stock_hash[:ticker]  = ticker
      stock_hash[:returns] = []
      stock_hash[:dates]   = []
      stock_list << stock_hash
    end
    data.each do |date_hash|
      date_hash.each do |k, v|
        stock_list.each do |stock|
          if stock[:ticker] == k
            stock[:returns] << v
            stock[:dates] << date_hash[:date]
          end
        end
      end
    end
    return stock_list
  end

  def stock_volatility
    stocks_volatility = {}
    self.returns.each do |stock|
      stocks_volatility[stock[:ticker]] = []
      count = 1
      stock[:returns].length.times do
        volatility_unit = standard_deviation(stock[:returns].take(count))
        stocks_volatility[stock[:ticker]] << volatility_unit
        count += 1
      end
    end
    return stocks_volatility
  end

  def check_volatility(single_date_returns, date)
    s_d_returns = {}
    single_date_returns.each do |k, v|
      index = self.returns.find {|stock| stock[:ticker] == k }[:dates].index(date)
      standard_deviation = self.volatility[k][index]
      s_d_returns[k] = v if standard_deviation >= min_volatility && standard_deviation <= max_volatility
    end
    return s_d_returns
  end

  def sort_all
    sorted_data = []
    count = 1
    data.each do |date_hash|
      single_date_returns = date_hash.reject { |k, v| v.class != Float && v.class != Integer }
      if count == 1
        sorted_returns = single_date_returns.sort_by(&:last).to_h
      else
        s_d_returns    = check_volatility(single_date_returns, date_hash[:date])
        sorted_returns = s_d_returns.sort_by(&:last).to_h
      end
      sorted_returns[:date] = date_hash[:date]
      sorted_data << sorted_returns
      count += 1
    end
    return sorted_data
  end

  def lasts
    last_returns = []
    self.all.each do |single_date_sorted_returns|
      single_date_lasts        = single_date_sorted_returns.first(size).to_h
      single_date_lasts[:date] = single_date_sorted_returns[:date]
      last_returns << single_date_lasts
    end
    return last_returns
  end

  def tops
    top_returns = []
    self.all.each do |single_date_sorted_returns|
      first_top_return_index = single_date_sorted_returns.length - 1
      last_top_return_index  = first_top_return_index - size
      single_date_tops       = {}
      single_date_sorted_returns.keys[last_top_return_index...first_top_return_index].each do |key|
        single_date_tops[key] = single_date_sorted_returns[key]
      end
      single_date_tops[:date] = single_date_sorted_returns[:date]
      top_returns << single_date_tops
    end
    return top_returns
  end

  def tops_with_ids
    samples = self.tops
    counter = 1
    add_ids(samples, counter)
  end

  def lasts_with_ids
    samples = self.lasts
    counter = 1
    add_ids(samples, counter)
  end

  def all_with_ids
    samples = self.all
    counter = 0
    add_ids(samples, counter)
  end

  def add_ids(samples, counter)
    samples = samples
    counter = counter
    samples.each do |single_date_top_returns|
      single_date_top_returns[:id] = counter
      counter += 1
    end
    return samples
  end

  def remove_ids(portfolio)
    portfolio.map! do |date_hash|
      date_hash.reject { |k, v| k === :id}
    end
  end

  def top_portfolio_returns
    returns = self.tops_with_ids
    portfolio_returns(returns)
  end

  def last_portfolio_returns
    returns = self.lasts_with_ids
    portfolio_returns(returns)
  end

  def portfolio_returns(returns)
    returns = returns
    all_returns = self.all_with_ids
    portfolio_returns = []
    all_returns.each do |single_date_sorted_returns|
      unless single_date_sorted_returns[:id] == 0
        single_date_portfolio_returns = {}
        returns.each do |single_date_top_returns|
          if single_date_top_returns[:id] == single_date_sorted_returns[:id]
            single_date_top_returns.each_key do |key|
              single_date_portfolio_returns[key] = single_date_sorted_returns[key]
            end
          end
        end
        portfolio_returns << single_date_portfolio_returns
      end
    end
    remove_ids(portfolio_returns)
  end
end
