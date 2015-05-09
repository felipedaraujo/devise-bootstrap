class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.integer :views
      t.integer :citations

      t.timestamps null: false
    end
  end
end
