# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      def create
        post = Post.user_post(post_params.merge(ip: request.remote_ip))

        if post.present? && post.persisted?
          render(json: CreatePostSerializer.new(post).serializable_hash.to_json, status: :created)
        else
          errors = post&.errors&.full_messages || ["User couldn't be created or persisted"]
          render(json: { errors: errors }, status: :unprocessable_entity)
        end
      end

      def top_rated
        default_top_n = 10

        n = params[:N].presence || default_top_n
        posts = Post.top_rated(n)

        render(json: posts, each_serializer: TopRatedPostsSerializer)
      end

      def authors_ips
        authors_ips = Post.authors_ips
        render(json: authors_ips, each_serializer: AuthorsIpsSerializer)
      end

      private

      def post_params
        params.require(:post).permit(:title, :body, :user_login)
      end
    end
  end
end
