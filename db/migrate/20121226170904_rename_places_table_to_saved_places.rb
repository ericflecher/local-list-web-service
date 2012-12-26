class RenamePlacesTableToSavedPlaces < ActiveRecord::Migration
  def up
    rename_table :places, :saved_places
  end

  def down
    rename_table :saved_places, :places
  end
end
