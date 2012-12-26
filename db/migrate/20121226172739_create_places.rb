class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :location
      t.string :ot_rid

      t.timestamps
    end
  end
end
