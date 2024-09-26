# frozen_string_literal: true

class Transaction < ApplicationRecord
  has_many :wallets

  TRANSACTION_TYPE = %w[CREDIT DEBIT SEND RECEIVE].freeze

  validates :transaction_type, presence: true, inclusion: TRANSACTION_TYPE
end
