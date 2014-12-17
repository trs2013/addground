class AddStatusColumnsToImportsAndImportItems < ActiveRecord::Migration
  def up
    add_column :imports, :status, :integer
    add_column :import_items, :status, :integer

    add_column :imports, :error, :text
    add_column :import_items, :error, :text

    change_column_default(:imports, :status, 0)
    change_column_default(:import_items, :status, 0)

    BatchScheduler.perform_async(Import.name, 'ImportStatusDefault')
    BatchScheduler.perform_async(ImportItem.name, 'ImportItemStatusDefault')
  end

  def down
    remove_column :imports, :status
    remove_column :import_items, :status
    remove_column :imports, :error
    remove_column :import_items, :error
  end
end
