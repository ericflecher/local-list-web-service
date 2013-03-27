class RemoveNameFromSavedPlaces < ActiveRecord::Migration
  def up
    remove_column :saved_places, :name
  end

  def down
    add_column :saved_places, :name, :string
  end
end
