# frozen_string_literal: true

module Accounts
  module Actions
    class CreateTeam
      def call(args:)
        @team_params = args[:team]

        validation_result = validate_team_creation
        return validation_result unless validation_result[:success]

        encrypt_password!
        create_team
      end

      def validate_team_creation
        return failed_to_create_team('Your username is already registered') if username_exists?

        { success: true }
      end

      def username_exists?
        Team.by_username(@team_params[:username]).exists?
      end

      private

      def create_team
        ActiveRecord::Base.transaction do
          team = Team.new(@team_params)
          return failed_to_create_team(team.errors.full_messages) unless team.save

          wallet = create_wallet(team)
          return failed_create_wallet(wallet) unless wallet.persisted?

          success_create_team(team, wallet)
        end
      end

      def create_wallet(team)
        Wallet.create(
          linked_owner_object: team,
          balance: 0
        )
      end

      def success_create_team(team, wallet)
        team.reload
        wallet.reload
        {
          success: true,
          team: team.as_json(except: [:password_digest]),
          wallet: wallet.as_json
        }
      end

      def failed_create_wallet(wallet)
        team.destroy!
        {
          success: false,
          error: 'Team created, but wallet creation failed',
          messages: wallet.errors.full_messages
        }
      end

      def failed_to_create_team(message)
        {
          success: false,
          error: message,
          messages: []
        }
      end

      def encrypt_password!
        return unless @team_params[:password]

        @team_params[:password_digest] = encrypt(@team_params[:password], @team_params[:username])
        @team_params.delete(:password)
      end

      def encrypt(password, username)
        Auth::Services::EncryptValue.encrypt_password(password, username)
      end
    end
  end
end
