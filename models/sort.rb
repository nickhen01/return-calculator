class Sort < ActiveRecord::Base
  serialize :data, Array

  def all
    sorted_data = []
    data.each do |date_hash|
      single_date_returns = date_hash.reject { |k, v| v.class != Float && v.class != Integer }
      # unless single_date_returns == {}
        sorted_returns        = single_date_returns.sort_by(&:last).to_h
        sorted_returns[:date] = date_hash[:date]
        sorted_data << sorted_returns
      # end
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
