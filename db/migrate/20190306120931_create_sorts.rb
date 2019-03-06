class CreateSorts < ActiveRecord::Migration[5.2]
  def change
    create_table :sorts do |t|
      t.text :data
      t.integer "size"

      t.timestamps
    end
  end
end
