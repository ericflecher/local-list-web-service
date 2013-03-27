class RemoveRefFromSavedPlaces < ActiveRecord::Migration
  def up
    remove_column :saved_places, :ref
  end

  def down
    add_column :saved_places, :ref, :string
  end
end
