class AddListOfReturnsToSort < ActiveRecord::Migration[5.2]
  def change
    add_column :sorts, :returns, :text
  end
end
