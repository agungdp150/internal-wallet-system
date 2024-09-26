# frozen_string_literal: true

module Auth
  module Services
    class EncryptValue
      def self.encrypt_password(password, username)
        salt = 'random_salt'
        Digest::SHA256.hexdigest("#{salt}#{password}#{username}#{salt}")
      end
    end
  end
end
