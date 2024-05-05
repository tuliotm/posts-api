# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def create
        @user = User.find_by(login: post_params[:user_login])

        if @user.nil?
          @user = User.new(login: post_params[:user_login])
          @user.save!
        end

        @post = Post.new(user_id: @user.id, title: post_params[:title], body: post_params[:body], ip: post_params[:ip])

        if @post.save
          render(json: @post, status: :created)
        else
          render(json: @post.errors, status: :unprocessable_entity)
        end
      end

      def top_rated
        n = params[:N].to_i
        @posts = Post.joins(:ratings)
          .select("posts.id, posts.title, posts.body, AVG(ratings.value) as average_rating")
          .group("posts.id")
          .order("average_rating DESC")
          .limit(n)

        render(json: @posts, each_serializer: TopRatedPostsSerializer)
      end

      private

      def post_params
        params.require(:post).permit(:title, :body, :user_login, :ip)
      end
    end
  end
end
