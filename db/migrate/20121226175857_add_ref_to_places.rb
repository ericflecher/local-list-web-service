class AddRefToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :ref, :string
  end
end
