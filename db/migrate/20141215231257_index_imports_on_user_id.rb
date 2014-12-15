class IndexImportsOnUserId < ActiveRecord::Migration
  disable_ddl_transaction!
  def change
    add_index :imports, :user_id, algorithm: :concurrently
  end
end
