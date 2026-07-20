class User < ApplicationRecord
  has_secure_password
  has_many :auth_keys

  def generate_auth_key
    auth_key = "titra-#{SecureRandom.hex(16)}"
    return AuthKey.create(user: self, key: auth_key)
  end
end
