# frozen_string_literal: true

require "swagger_helper"

RSpec.describe("api/v1/posts", type: :request) do
  path "/api/v1/posts" do
    post "create post" do
      tags "Post"
      consumes "application/json"
      produces "application/json"
      parameter name: :post_attributes,
        in: :body,
        schema: { "$ref": "#/components/schemas/CreateNewPost" }

      response "201", "created" do
        let(:user) { create(:user) }
        let(:post_attributes) do
          {
            "post": {
              "title": FFaker::Lorem.sentence,
              "body": FFaker::Lorem.paragraph,
              "user_login": user.login,
            },
          }
        end

        schema "$ref": "#/components/schemas/RenderNewPost"

        run_test!
      end

      response "422", "error" do
        let(:user) { create(:user) }
        let(:post_attributes) do
          {
            "post": {
              "body": FFaker::Lorem.paragraph,
              "user_login": user.login,
            },
          }
        end

        schema "$ref": "#/components/schemas/ErrorsMessages"

        run_test!
      end
    end
  end
end
