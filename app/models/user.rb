# frozen_string_literal: true

class User < ApplicationRecord
  #== VALIDATIONS ========================================
  validates :login, presence: true, uniqueness: true

  #== ASSOCIATIONS =======================================
  has_many :posts
  has_many :ratings
end
