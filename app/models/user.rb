class User < ActiveRecord::Base
  attr_accessible :email, :token
  has_many :places
end
