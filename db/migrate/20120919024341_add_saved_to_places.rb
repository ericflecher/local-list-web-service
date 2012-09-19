class AddSavedToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :saved, :boolean
  end
end
