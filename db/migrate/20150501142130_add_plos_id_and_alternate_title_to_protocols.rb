class AddPlosIdAndAlternateTitleToProtocols < ActiveRecord::Migration
  def change
    add_column :protocols, :plos_id, :string
    add_column :protocols, :alternate_title, :string
  end
end
