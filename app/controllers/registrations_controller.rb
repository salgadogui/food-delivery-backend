class RegistrationsController < ApplicationController
  rescue_from User::InvalidToken, with: :not_authorized

  skip_forgery_protection only: [:create, :me]
  before_action :authenticate!, only: [:me]

  def me
    render json: { id: current_user.id, email: current_user.email }
  end

  def sign_in
    user = User.find_by(email: sign_in_params[:email])

    if !user || !user.valid_password?(sign_in_params[:password])
      render json: { message: "Nope!" }, status: 401
    else
      token = User.token_for(user) 
      render json: { email: user.email, token: token }
    end
  end

  def create
    @user = User.new(user_params)
    if @user.role == 'admin'
      render json: { error: 'Role admin is not allowed.' }, status: :forbidden
    elsif @user.save
      render json: {"email": @user.email}
    end
  end

  private

    def sign_in_params
      params.require(:login).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :role)
    end

    def not_authorized(e)
      render json: { message: "Nope!" }, status: 401
    end
end
