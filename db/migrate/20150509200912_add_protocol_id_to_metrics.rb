class AddProtocolIdToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :protocol_id, :integer
  end
end
