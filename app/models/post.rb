# frozen_string_literal: true

class Post < ApplicationRecord
  #== ASSOCIATIONS =======================================
  belongs_to :user
  has_many :ratings

  #== VALIDATIONS ========================================
  validates :title, presence: true
  validates :body, presence: true
  validates :ip, presence: true

  #== CLASS METHODS ======================================
  class << self
    def user_post(params)
      user = User.find_or_create_by(login: params[:user_login])

      return unless user.persisted?

      post = user.posts.new(
        title: params[:title],
        body: params[:body],
        ip: params[:ip],
      )

      post.save
      post
    end

    def top_rated(limit)
      joins(:ratings)
        .select("posts.id, posts.title, posts.body, AVG(ratings.value) as average_rating")
        .group("posts.id")
        .order("average_rating DESC")
        .limit(limit)
    end

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
