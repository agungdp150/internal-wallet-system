# frozen_string_literal: true

class Api::V1::AuthController < ApplicationController
  def create
    user = User.by_username(params[:username]).first

    if user&.authenticate(params[:password], params[:username])
      session[:user_id] = user.id
      render json: { message: 'Login successful', user: }, status: :ok
    else
      render json: { error: 'Invalid username or password' }, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end
