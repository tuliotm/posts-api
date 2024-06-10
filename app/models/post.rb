# frozen_string_literal: true

class Post < ApplicationRecord
  #== ASSOCIATIONS =======================================
  belongs_to :user
  has_many :ratings

  #== VALIDATIONS ========================================
  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  #== SCOPES =============================================
  scope :top_rated, ->(limit) {
    joins(:ratings)
      .select("posts.id, posts.title, posts.body, AVG(ratings.value) as average_rating")
      .group("posts.id")
      .order("average_rating DESC")
      .limit(limit)
  }
end
