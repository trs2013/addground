class AddStatusToImportItems < ActiveRecord::Migration
  def change
    add_column :import_items, :status, :integer
    change_column_default(:import_items, :status, 0)
  end
end
