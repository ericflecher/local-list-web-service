class RemoveArchivedFromSavedPlaces < ActiveRecord::Migration
  def up
    remove_column :saved_places, :archived
  end

  def down
    add_column :saved_places, :archived, :boolean
  end
end
