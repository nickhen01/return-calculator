class Sort
  attr_reader :portfolio_size, :data

  def initialize(portfolio_size, data)
    @portfolio_size = portfolio_size
    @data           = data
  end

  def all
    @sorted_data = []
    data.each do |date_hash|
      single_date_returns   = date_hash.reject { |k, v| k === :date }
      sorted_returns        = single_date_returns.sort_by(&:last).to_h
      sorted_returns[:date] = date_hash[:date]
      @sorted_data << sorted_returns
    end
    return @sorted_data
  end

  def lasts
    last_returns = []
    self.all.each do |single_date_sorted_returns|
      single_date_lasts        = single_date_sorted_returns.first(portfolio_size).to_h
      single_date_lasts[:date] = single_date_sorted_returns[:date]
      last_returns << single_date_lasts
    end
    return last_returns
  end

  def tops
    top_returns = []
    self.all.each do |single_date_sorted_returns|
      first_top_return_index = single_date_sorted_returns.length - 1
      last_top_return_index  = first_top_return_index - portfolio_size
      single_date_tops       = {}
      single_date_sorted_returns.keys[last_top_return_index...first_top_return_index].each do |key|
        single_date_tops[key] = single_date_sorted_returns[key]
      end
      single_date_tops[:date] = single_date_sorted_returns[:date]
      top_returns << single_date_tops
    end
    return top_returns
  end
end