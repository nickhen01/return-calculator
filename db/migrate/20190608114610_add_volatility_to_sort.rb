class AddVolatilityToSort < ActiveRecord::Migration[5.2]
  def change
    add_column :sorts, :volatility, :text
  end
end
