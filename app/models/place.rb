class Place < ActiveRecord::Base
  attr_accessible :id, :user_id, :uid, :name, :ref, :saved, :come_back
  belongs_to :user
end
