# frozen_string_literal: true

module Api
  module V1
    class RatingsController < ApplicationController
      before_action :set_post

      def create
        rating = Rating.new(rating_params)

        if rating.save
          average = Rating.where(post_id: rating_params[:post_id]).average(:value).round(2)
          render(json: { average: average, post_id: rating_params[:post_id] }, status: :created)
        else
          render(json: { errors: rating.errors.full_messages }, status: :unprocessable_entity)
        end
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end

      def set_post
        @post = Post.find_by(id: rating_params[:post_id])
      end
    end
  end
end
