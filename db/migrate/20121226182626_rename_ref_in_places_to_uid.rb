class RenameRefInPlacesToUid < ActiveRecord::Migration
  def change
    rename_column :places, :ref, :uid
  end
end
