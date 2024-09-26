# frozen_string_literal: true

class Api::V1::StocksController < ApplicationController
  def index
    stocks = Stock.includes(:wallet).all

    render json: { count: stocks.count, data: stocks }, status: :ok
  end

  def show
    stock = Stock.includes(:wallet).by_id(params[:id]).first

    if stock
      render json: { data: stock }, status: :ok
    else
      render json: { error: 'Stock not found' }, status: :not_found
    end
  end

  def create
    result = Accounts::Actions::CreateStock.new.call(args: { stock: stock_params })

    if result[:success]
      render json: { data: { stock: result[:stock], wallet: result[:wallet] } }, status: :created
    else
      render json: format_error(result[:error], result[:messages]), status: :unprocessable_entity
    end
  end

  def update
    stock = Stock.by_id(params[:id]).first

    if stock&.update(stock_params)
      render json: { data: stock }, status: :ok
    else
      render json: format_error('Update failed', stock&.errors&.full_messages), status: :unprocessable_entity
    end
  end

  def destroy
    stock = Stock.by_id(params[:id]).first

    if stock&.destroy
      render json: { data: stock }, status: :ok
    else
      render json: format_error('Delete failed', stock&.errors&.full_messages), status: :unprocessable_entity
    end
  end

  private

  def stock_params
    params.require(:stock).permit(%i[username name password])
  end

  def format_error(error_message, messages)
    {
      error: error_message,
      messages: messages || ['An unexpected error occurred']
    }
  end
end
