class ChangeMethodFormatOnProtocol < ActiveRecord::Migration
  def change
    change_column :protocols, :method, :text
  end
end
