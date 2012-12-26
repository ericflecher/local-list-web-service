class Place < ActiveRecord::Base
  attr_accessible :uid, :name, :city, :location, :ot_rid
end
