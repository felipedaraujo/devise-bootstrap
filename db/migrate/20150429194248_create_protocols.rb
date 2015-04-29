class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.string :name
      t.string :procedure
      t.string :source
      t.string :author

      t.timestamps null: false
    end
  end
end
