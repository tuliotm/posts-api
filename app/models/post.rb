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

  scope :with_multiple_authors_ips, -> {
    joins(:user)
      .select("posts.ip, ARRAY_AGG(DISTINCT users.login) AS authors")
      .group("posts.ip")
      .having("COUNT(DISTINCT users.id) > 1")
  }
end
