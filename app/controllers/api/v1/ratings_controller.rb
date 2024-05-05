# frozen_string_literal: true

module Api
  module V1
    class RatingsController < ApplicationController
      def create
        @rating = Rating.find_by(user_id: rating_params[:user_id], post_id: rating_params[:post_id])

        if @rating
          render(json: @rating.errors, status: :unprocessable_entity)
        else
          @rating = Rating.new(rating_params)

          if @rating.save
            average = Rating.where(post_id: rating_params[:post_id]).average(:value).round(2)

            render(json: average, status: :created)
          else
            render(json: @rating.errors, status: :unprocessable_entity)
          end
        end
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end
    end
  end
end
