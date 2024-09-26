# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  def index
    users = User.includes(:wallet).all

    render json: { count: users.count, data: users }, status: :ok
  end

  def show
    user = User.includes(:wallet).by_id(params[:id]).first

    if user
      render json: { data: user }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  def create
    result = Accounts::Actions::CreateUser.new.call(args: { user: user_params })

    if result[:success]
      render json: { data: { user: result[:user], wallet: result[:wallet] } }, status: :created
    else
      render json: format_error(result[:error], result[:messages]), status: :unprocessable_entity
    end
  end

  def update
    user = User.by_id(params[:id]).first

    if user&.update(user_params)
      render json: { data: user }, status: :ok
    else
      render json: format_error('Update failed', user&.errors&.full_messages), status: :unprocessable_entity
    end
  end

  def destroy
    user = User.by_id(params[:id]).first

    if user&.destroy
      render json: { data: user }, status: :ok
    else
      render json: format_error('Delete failed', user&.errors&.full_messages), status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(%i[username name password])
  end

  def format_error(error_message, messages)
    {
      error: error_message,
      messages: messages || ['An unexpected error occurred']
    }
  end
end
