# frozen_string_literal: true

class Api::V1::WalletsController < ApplicationController
  def index
    wallets = Wallet.includes(:wallet).all

    render json: { count: wallets.count, data: wallets }, status: :ok
  end

  def show
    wallet = Wallet.by_id(params[:id]).first

    if stock
      render json: { data: wallet }, status: :ok
    else
      render json: { error: 'Wallet not found' }, status: :not_found
    end
  end
end
