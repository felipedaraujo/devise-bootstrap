class AddMethodToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :method, :string, array: true, default: []
  end
end
