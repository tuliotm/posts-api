# frozen_string_literal: true

require "swagger_helper"

RSpec.describe("api/v1/ratings", type: :request) do
  path "/api/v1/ratings" do
    post "create ratings" do
      tags "Rating"
      consumes "application/json"
      produces "application/json"
      parameter name: :rating_attributes,
        in: :body,
        schema: { "$ref": "#/components/schemas/CreateNewRating" }

      response "201", "created" do
        let(:post_instance) { create(:post) }
        let(:rating_attributes) do
          {
            "rating": {
              "user_id": post_instance.user.id,
              "post_id": post_instance.id,
              "value": rand(1..5),
            },
          }
        end

        schema "$ref": "#/components/schemas/RenderNewRating"

        run_test!
      end

      response "422", "error" do
        let(:post_instance) { create(:post) }
        let(:rating_attributes) do
          {
            "rating": {
              "post_id": post_instance.id,
              "value": rand(1..5),
            },
          }
        end

        schema "$ref": "#/components/schemas/ErrorsMessages"

        run_test!
      end
    end
  end
end
