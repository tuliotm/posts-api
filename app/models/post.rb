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

  #== CLASS METHODS ======================================
  class << self
    def authors_ips
      ips = select(:ip).distinct
      result = []

      ips.each do |ip_record|
        users = User.joins(:posts).where(posts: { ip: ip_record.ip }).distinct
        if users.count > 1
          result << { ip: ip_record.ip, authors: users.pluck(:login) }
        end
      end

      result
    end
  end
end
