class AddYelpIdToSavedPlaces < ActiveRecord::Migration
  def change
    add_column :saved_places, :yelp_id, :string
  end
end
