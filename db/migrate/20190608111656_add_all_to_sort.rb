class AddAllToSort < ActiveRecord::Migration[5.2]
  def change
    add_column :sorts, :all, :text
  end
end
