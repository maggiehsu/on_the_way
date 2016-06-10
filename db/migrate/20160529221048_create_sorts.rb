class CreateSorts < ActiveRecord::Migration
  def change
    create_table :sorts do |t|
      t.string :sort_method

      t.timestamps null: false
    end
  end
end
