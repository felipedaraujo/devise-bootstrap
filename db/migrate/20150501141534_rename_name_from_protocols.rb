class RenameNameFromProtocols < ActiveRecord::Migration
  def change
    rename_column :protocols, :name, :title
  end
end
