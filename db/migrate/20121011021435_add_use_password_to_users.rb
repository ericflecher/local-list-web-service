class AddUsePasswordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_password, :boolean
  end
end
