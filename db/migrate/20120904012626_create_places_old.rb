class CreatePlacesOld < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.string :name
      t.string :ref

      t.timestamps
    end
  end
end
