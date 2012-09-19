class AddComeBackToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :come_back, :boolean
  end
end
