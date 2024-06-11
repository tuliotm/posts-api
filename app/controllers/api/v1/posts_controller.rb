# frozen_string_literal: true

module Api
  module V1
    class PostsController < ApplicationController
      before_action :validate_user, only: [:create]

      DEFAULT_TOP_N = 10

      def create
        user = User.find_or_create_by(login: post_params[:user_login])

        post = user.posts.new(
          title: post_params[:title],
          body: post_params[:body],
          ip: request.remote_ip,
        )

        if post.save
          render(json: CreatePostSerializer.new(post).serializable_hash.to_json, status: :created)
        else
          errors = post&.errors&.full_messages
          render(json: { errors: errors }, status: :unprocessable_entity)
        end
      end

      def top_rated
        n = params[:N].presence || DEFAULT_TOP_N
        posts = Post.top_rated(n)

        render(json: posts, each_serializer: TopRatedPostsSerializer)
      end

      def authors_ips
        result = Post.joins(:user)
                     .select('posts.ip, ARRAY_AGG(DISTINCT users.login) AS authors')
                     .group('posts.ip')
                     .having('COUNT(DISTINCT users.id) > 1')
                     .map do |record|
                       { ip: record.ip, authors: record.authors }
                     end

        render(json: result, each_serializer: AuthorsIpsSerializer)
      end

      private

      def post_params
        params.require(:post).permit(:title, :body, :user_login)
      end

      def validate_user
        if post_params[:user_login].blank?
          render(json: { errors: ["User login cannot be blank"] }, status: :bad_request)
        end
      end
    end
  end
end
