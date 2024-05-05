# frozen_string_literal: true

class Rating < ApplicationRecord
  #== ASSOCIATIONS =======================================
  belongs_to :post
  belongs_to :user

  #== VALIDATIONS ========================================
  validates :value, inclusion: { in: 1..5 }, presence: true
  validates :user_id, uniqueness: { scope: :post_id }

  #== CLASS METHODS ======================================
  class << self
    def create_and_calculate_average(params)
      transaction do
        rating = find_by(user_id: params[:user_id], post_id: params[:post_id])

        return { status: :unprocessable_entity, errors: ["Post already rated."] } if rating

        rating = new(params)

        if rating.save
          average = where(post_id: params[:post_id]).average(:value).round(2)
          return { status: :created, average: average }
        else
          return { status: :unprocessable_entity, errors: rating.errors.full_messages }
        end
      end
    end
  end
end
