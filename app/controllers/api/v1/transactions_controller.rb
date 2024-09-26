# frozen_string_literal: true

class Api::V1::TransactionsController < ApplicationController
  def index
    transactions = Transaction.includes(:wallet).all

    render json: { count: transactions.count, data: transactions }, status: :ok
  end

  def show
    transaction = Transaction.by_id(params[:id]).first

    if stock
      render json: { data: transaction }, status: :ok
    else
      render json: { error: 'Transaction not found' }, status: :not_found
    end
  end

  def create
    result = Transactions::Actions::CreateTransaction.new.call(args: { transaction: transaction_params })

    if result[:success]
      render json: { data: { user: result[:transaction] } }, status: :created
    else
      render json: format_error(result[:error], result[:messages]), status: :unprocessable_entity
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(%i[balance wallet_id target_wallet_id transaction_type])
  end

  def format_error(error_message, messages)
    {
      error: error_message,
      messages: messages || ['An unexpected error occurred']
    }
  end
end
