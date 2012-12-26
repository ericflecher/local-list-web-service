class User < ActiveRecord::Base
  attr_accessor :password
  before_save :encrypt_password
  
  attr_accessible :email, :token, :password, :use_password
  validates_presence_of :email
  validates_uniqueness_of :email
  has_many :saved_places
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  def self.authenticate(email, password)
    user = find_by_email(email)
    if user && user.use_password == true && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    elsif user && user.use_password == false
      user
    else
      nil
    end
  end
end
