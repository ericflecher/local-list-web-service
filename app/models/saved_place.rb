class SavedPlace < ActiveRecord::Base
  attr_accessible :id, :user_id, :uid, :name, :ref, :saved, :come_back, :archived
  belongs_to :user
end
