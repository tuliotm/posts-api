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
  end
end
