class Average
  attr_reader :portfolio_size, :portfolio

  def initialize(portfolio_size, portfolio)
    @portfolio_size = portfolio_size
    @portfolio      = portfolio
  end

  def average_return
    portfolio_average_return = []
    portfolio.each do |on_date_portfolio|
      sum_return = 0
      portfolio_without_date = on_date_portfolio.reject { |k, v| k == :date }
      portfolio_without_date.each_value do |each_return|
        sum_return += each_return
      end
      average_return                   = sum_return / portfolio_size
      on_date_average                  = {}
      on_date_average[:average_return] = average_return
      on_date_average[:date]           = on_date_portfolio[:date]
      portfolio_average_return << on_date_average
    end
    return portfolio_average_return
  end
end