# frozen_string_literal: true

class Rating < ApplicationRecord
  #== ASSOCIATIONS =======================================
  belongs_to :post
  belongs_to :user

  #== VALIDATIONS ========================================
  validates :value, inclusion: { in: 1..5 }, presence: true
  validates :user_id, uniqueness: { scope: :post_id }
end
