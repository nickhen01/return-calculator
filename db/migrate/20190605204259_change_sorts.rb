class ChangeSorts < ActiveRecord::Migration[5.2]
  def change
    add_column :sorts, :min_volatility, :float
    add_column :sorts, :max_volatility, :float
  end
end
