class User < ApplicationRecord
  class InvalidToken < StandardError; end
  # ... placeholder

  enum :role, [:admin, :seller, :buyer]
  has_many :stores

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.token_for(user)
    jwt_headers = { exp: 1.hour.from_now.to_i }
    payload = { id: user.id, email: user.email, role: user.role }
    JWT.encode payload.merge(jwt_headers), Rails.application.credentials.jwt_secret_key, "HS256"
  end

  def self.from_token(token)
    begin
      decoded = JWT.decode token, Rails.application.credentials.jwt_secret_key, true, { algorithm: "HS256" }
      user_data = decoded[0].with_indifferent_access

    rescue JWT::ExpiredSignature
      raise InvalidToken.new
    end
  end
end
