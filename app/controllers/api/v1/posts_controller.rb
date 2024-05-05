# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def create
        @user = User.find_by(login: post_params[:user_login])

        if @user.nil?
          @user = User.new(login: post_params[:user_login])
          @user.save
        end

        user_ip = request.remote_ip

        @post = Post.new(user_id: @user.id, title: post_params[:title], body: post_params[:body], ip: user_ip)

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

      def authors_ips
        ips = Post.select(:ip).distinct
        authors_ips = []

        ips.each do |ip|
          users = User.joins(:posts).where(posts: { ip: ip.ip }).distinct
          if users.count > 1
            authors_ips << { ip: ip.ip, authors: users.pluck(:login) }
          end
        end

        render(json: authors_ips)
      end

      private

      def post_params
        params.require(:post).permit(:title, :body, :user_login)
      end
    end
  end
end
