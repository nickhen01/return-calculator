class Sort
  attr_reader :portfolio_size, :data
  def initialize(portfolio_size, data)
    @portfolio_size = portfolio_size
    @data           = data
  end

  def all
    @sorted_data = []
    @data.each do |date_hash|
      on_recurrence_returns = date_hash.reject { |k, v| k === :date }
      sorted_returns = on_recurrence_returns.sort_by(&:last).to_h
      sorted_returns[:date] = date_hash[:date]
      @sorted_data << sorted_returns
    end
    return @sorted_data
  end

  def lasts
    self.all
    last_selected = []
    @sorted_data.each do |sorted_hash|
      on_recurrence_lasts = sorted_hash.first(@portfolio_size).to_h
      on_recurrence_lasts[:date] = sorted_hash[:date]
      last_selected << on_recurrence_lasts
    end
    return last_selected
  end

  def tops
    self.all
    top_selected = []
    @sorted_data.each do |sorted_hash|
      first = sorted_hash.length - 1
      number_to_first = first - @portfolio_size
      on_recurrence_tops = {}
      sorted_hash.keys[number_to_first...first].each do |key|
        on_recurrence_tops[key] = sorted_hash[key]
      end
      on_recurrence_tops[:date] = sorted_hash[:date]
      top_selected << on_recurrence_tops
    end
    return top_selected
  end
end