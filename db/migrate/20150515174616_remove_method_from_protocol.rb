class RemoveMethodFromProtocol < ActiveRecord::Migration
  def change
    remove_column :protocols, :method
  end
end
