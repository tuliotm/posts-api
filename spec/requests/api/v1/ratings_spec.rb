# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Api::V1::Ratings", type: :request) do
  describe "POST /create" do
    context "success" do
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

      before do
        post api_v1_ratings_path, params: rating_attributes
      end

      it "returns status code created" do
        expect(response).to(have_http_status(:created))
      end

      it "returns the correct average rating" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response).to(be_between("1", "5").inclusive)
        expect(parsed_response.to_s.split(".").last.size).to(be <= 2)
      end
    end

    context "failure" do
      context "when data is nil" do
        let(:invalid_attributes) do
          {
            "rating": {
              "user_id": nil,
              "post_id": nil,
              "value": nil,
            },
          }
        end

        before do
          post api_v1_ratings_path, params: invalid_attributes
        end

        it "returns status code unprocessable entity" do
          expect(response).to(have_http_status(:unprocessable_entity))
        end
      end

      context "when value is out of range" do
        let(:post_instance) { create(:post) }
        let(:invalid_value) do
          {
            "rating": {
              "user_id": post_instance.user.id,
              "post_id": post_instance.id,
              "value": 6,
            },
          }
        end

        before do
          post api_v1_ratings_path, params: invalid_value
        end

        it "returns status code unprocessable entity" do
          expect(response).to(have_http_status(:unprocessable_entity))
        end

        it "returns the correct error message" do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["value"]).to(eq(["is not included in the list"]))
        end
      end

      context "when already rated by the user" do
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

        let(:already_rated) do
          {
            "rating": {
              "user_id": post_instance.user.id,
              "post_id": post_instance.id,
              "value": (1..5),
            },
          }
        end

        before do
          post api_v1_ratings_path, params: rating_attributes
        end

        it "returns status code unprocessable entity" do
          post "/api/v1/ratings", params: already_rated
          expect(response).to(have_http_status(:unprocessable_entity))
        end
      end
    end
  end
end
