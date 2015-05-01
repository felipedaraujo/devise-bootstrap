class RenameProcedureAndSourceFromProtocols < ActiveRecord::Migration
  def change
    rename_column :protocols, :procedure, :method
    rename_column :protocols, :source, :journal
  end
end
