class RemoveUidFromSavedPlaces < ActiveRecord::Migration
  def up
    remove_column :saved_places, :uid
  end

  def down
    add_column :saved_places, :uid, :string
  end
end
