class SavedPlace < ActiveRecord::Base
  attr_accessible :id, :user_id, :come_back, :yelp_id
  belongs_to :user
end
