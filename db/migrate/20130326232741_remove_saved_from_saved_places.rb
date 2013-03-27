class RemoveSavedFromSavedPlaces < ActiveRecord::Migration
  def up
    remove_column :saved_places, :saved
  end

  def down
    add_column :saved_places, :saved, :string
  end
end
