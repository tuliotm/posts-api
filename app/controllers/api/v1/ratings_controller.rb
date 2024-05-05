# frozen_string_literal: true

module Api
  module V1
    class RatingsController < ApplicationController
      def create
        result = Rating.create_and_calculate_average(rating_params)

        if result[:status] == :created
          render(json: { average: result[:average] }, status: :created)
        else
          render(json: { errors: result[:errors] }, status: result[:status])
        end
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end
    end
  end
end
