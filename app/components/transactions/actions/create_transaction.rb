# frozen_string_literal: true

module Transactions
  module Actions
    class CreateTransaction
      TIME_FORMAT = '%H:%M %Z'

      def call(args:)
        @transaction_params = args[:transaction]

        validation_result = validate_transaction
        return validation_result unless validation_result[:success]

        create_transaction
      end

      def validate_transaction
        return failed_transaction('Your balance is not enough') if insufficient_wallet_balance?

        { success: true }
      end

      def insufficient_wallet_balance?
        return false unless %w[DEBIT SEND].include?(@transaction_params[:transaction_type])

        wallet.balance < @transaction_params[:balance]
      end

      def wallet
        Wallet.by_id(@transaction_params[:wallet_id]).first
      end

      def target_wallet
        Wallet.by_id(@transaction_params[:target_wallet_id]).first
      end

      def create_transaction
        ActiveRecord::Base.transaction do
          transaction = Transaction.new(params)
          return failed_transaction(transaction.errors.full_messages) unless transaction.save

          if target_wallet.present?
            target_transaction = Transaction.new(target_wallet_transaction_params)
            return failed_transaction(target_transaction.errors.full_messages) unless target_transaction.save

            update_wallet_balance(-@transaction_params[:balance])
            update_target_wallet_balance(@transaction_params[:balance])
          else
            update_wallet_balance(@transaction_params[:balance])
          end

          success_transaction(transaction)
        end
      end

      def update_wallet_balance(amount)
        wallet.update!(balance: wallet.balance + amount)
      end

      def update_target_wallet_balance(amount)
        target_wallet.update!(balance: target_wallet.balance + amount)
      end

      def params
        {
          wallet_id: @transaction_params[:wallet_id],
          balance: @transaction_params[:balance],
          transaction_time: Time.now.strftime(TIME_FORMAT),
          transaction_date: Time.now.to_date,
          transaction_type: @transaction_params[:transaction_type]
        }
      end

      def target_wallet_transaction_params
        {
          wallet_id: @transaction_params[:target_wallet_id],
          balance: @transaction_params[:balance],
          transaction_time: Time.now.strftime(TIME_FORMAT),
          transaction_date: Time.now.to_date,
          transaction_type: 'RECEIVE'
        }
      end

      def success_transaction(transaction)
        transaction.reload
        {
          success: true,
          transaction: transaction.as_json
        }
      end

      def failed_transaction(message)
        {
          success: false,
          error: message,
          messages: []
        }
      end
    end
  end
end
