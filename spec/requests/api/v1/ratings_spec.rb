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
        parsed_response = JSON.parse(response.body)["average"].to_f
        expect(parsed_response).to(be_between(1, 5).inclusive)
        expect(parsed_response.to_s.split(".").last.size).to(be <= 2)
      end

      it "persists the rating in the database" do
        created_rating = Rating.find_by(
          user_id: rating_attributes[:rating][:user_id],
          post_id: rating_attributes[:rating][:post_id],
        )
        expect(created_rating).not_to(be_nil)
        expect(created_rating.value).to(eq(rating_attributes[:rating][:value]))
      end

      it "associates the rating with the correct post and user" do
        created_rating = Rating.find_by(
          user_id: rating_attributes[:rating][:user_id],
          post_id: rating_attributes[:rating][:post_id],
        )
        expect(created_rating.user_id).to(eq(post_instance.user.id))
        expect(created_rating.post_id).to(eq(post_instance.id))
      end
    end

    context "failure" do
      context "when post is nil" do
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

        it "returns status code unprocessable_entity" do
          expect(response).to(have_http_status(:unprocessable_entity))
        end

        it "returns error messages when post is null or don't exists" do
          json_response = JSON.parse(response.body)
          expect(json_response["errors"]).to(include("Post must exist"))
        end
      end

      context "when user and value is nil" do
        let(:user_post) { create(:post) }
        let(:invalid_attributes) do
          {
            "rating": {
              "user_id": nil,
              "post_id": user_post.id,
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

        it "return errors messages for every null fild" do
          json_response = JSON.parse(response.body)
          expect(json_response["errors"]).to(include(
            "User must exist",
            "Value is not included in the list",
            "Value can't be blank",
          ))
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

        it "returns the correct error message" do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["errors"]).to(eq(["Value is not included in the list"]))
          expect(response).to(have_http_status(:unprocessable_entity))
        end
      end

      context "when already rated by the user" do
        let(:rating) { create(:rating) }
        let(:rating_attributes) do
          {
            "rating": {
              "user_id": rating.user.id,
              "post_id": rating.post.id,
              "value": rand(1..5),
            },
          }
        end

        before do
          post api_v1_ratings_path, params: rating_attributes
        end

        it "returns status code unprocessable entity" do
          json_response = JSON.parse(response.body)
          expect(json_response["errors"]).to(include("User has already been taken"))
          expect(response).to(have_http_status(:unprocessable_entity))
        end
      end
    end
  end
end
