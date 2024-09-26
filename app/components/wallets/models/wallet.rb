# frozen_string_literal: true

class Wallet < ApplicationRecord
  belongs_to :linked_owner_object, polymorphic: true

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  def self.by_id(id)
    return nil unless id

    where(id:)
  end
end
