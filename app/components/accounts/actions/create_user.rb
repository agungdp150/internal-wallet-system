# frozen_string_literal: true

module Accounts
  module Actions
    class CreateUser
      def call(args:)
        @user_params = args[:user]

        validation_result = validate_user_creation
        return validation_result unless validation_result[:success]

        encrypt_password!
        create_user
      end

      def validate_user_creation
        return failed_to_create_user('Your username is already registered') if username_exists?

        { success: true }
      end

      def username_exists?
        User.by_username(@user_params[:username]).exists?
      end

      private

      def create_user
        ActiveRecord::Base.transaction do
          user = User.new(@user_params)
          return failed_to_create_user(user.errors.full_messages) unless user.save

          wallet = create_wallet(user)
          return failed_create_wallet(wallet) unless wallet.persisted?

          success_create_user(user, wallet)
        end
      end

      def create_wallet(user)
        Wallet.create(
          linked_owner_object: user,
          balance: 0
        )
      end

      def success_create_user(user, wallet)
        user.reload
        wallet.reload
        {
          success: true,
          user: user.as_json(except: [:password_digest]),
          wallet: wallet.as_json
        }
      end

      def failed_create_wallet(wallet)
        user.destroy!
        {
          success: false,
          error: 'User created, but wallet creation failed',
          messages: wallet.errors.full_messages
        }
      end

      def failed_to_create_user(message)
        {
          success: false,
          error: message,
          messages: []
        }
      end

      def encrypt_password!
        return unless @user_params[:password]

        @user_params[:password_digest] = encrypt(@user_params[:password], @user_params[:username])
        @user_params.delete(:password)
      end

      def encrypt(password, username)
        Auth::Services::EncryptValue.encrypt_password(password, username)
      end
    end
  end
end
