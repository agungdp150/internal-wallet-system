# frozen_string_literal: true

module Accounts
  module Actions
    class CreateStock
      def call(args:)
        @stock_params = args[:stock]

        validation_result = validate_stock_creation
        return validation_result unless validation_result[:success]

        encrypt_password!
        create_stock
      end

      def validate_stock_creation
        return failed_to_create_stock('Your username is already registered') if username_exists?

        { success: true }
      end

      def username_exists?
        Stock.by_username(@stock_params[:username]).exists?
      end

      private

      def create_stock
        ActiveRecord::Base.transaction do
          stock = Stock.new(@stock_params)
          return failed_to_create_stock(stock.errors.full_messages) unless stock.save

          wallet = create_wallet(stock)
          return failed_create_wallet(wallet) unless wallet.persisted?

          success_create_stock(stock, wallet)
        end
      end

      def create_wallet(stock)
        Wallet.create(
          linked_owner_object: stock,
          balance: 0
        )
      end

      def success_create_stock(stock, wallet)
        stock.reload
        wallet.reload
        {
          success: true,
          stock: stock.as_json(except: [:password_digest]),
          wallet: wallet.as_json
        }
      end

      def failed_create_wallet(wallet)
        stock.destroy!
        {
          success: false,
          error: 'Stock created, but wallet creation failed',
          messages: wallet.errors.full_messages
        }
      end

      def failed_to_create_stock(message)
        {
          success: false,
          error: message,
          messages: []
        }
      end

      def encrypt_password!
        return unless @stock_params[:password]

        @stock_params[:password_digest] = encrypt(@stock_params[:password], @stock_params[:username])
        @stock_params.delete(:password)
      end

      def encrypt(password, username)
        Auth::Services::EncryptValue.encrypt_password(password, username)
      end
    end
  end
end
