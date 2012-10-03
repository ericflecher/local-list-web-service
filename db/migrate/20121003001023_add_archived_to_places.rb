class AddArchivedToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :archived, :boolean
  end
end
