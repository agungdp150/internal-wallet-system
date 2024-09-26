# frozen_string_literal: true

class Stock < ApplicationRecord
  has_one :wallet, as: :linked_owner_object, dependent: :destroy

  def as_json(options = {})
    super(options.merge(
      except: [:password_digest],
      include: { wallet: { only: %i[id balance] } }
    ))
  end

  def self.by_id(id)
    return nil unless id

    where(id:)
  end

  def self.by_name(name)
    return nil unless name

    where(name:)
  end

  def self.by_username(username)
    return nil unless name

    where(username:)
  end

  def authenticate(input_password, username)
    password_digest == encrypt(input_password, username)
  end

  private

  def encrypt(password, username)
    Auth::Services::EncryptValue.encrypt_password(password, username)
  end
end
