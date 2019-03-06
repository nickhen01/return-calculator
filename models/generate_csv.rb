class GenerateCsv
  attr_reader :tops, :lasts

  def initialize(tops = [], lasts = [])
    @tops  = tops
    @lasts = lasts
  end

  def sorted_with_tops_and_lasts
    CSV.generate do |csv|
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

  def average_with_tops_and_lasts
    CSV.generate do |csv|
      csv << ["Tops"]
      csv << ["average_return","date"]
      tops.each do |single_date_returns|
        csv << single_date_returns.values
      end
      csv << ["Lasts"]
      csv << ["average_return","date"]
      lasts.each do |single_date_returns|
        csv << single_date_returns.values
      end
    end
  end
end