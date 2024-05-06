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

  path "/api/v1/posts/top_rated" do
    get "get top rated posts with N params" do
      tags "Post"
      produces "application/json"
      parameter name: :N, in: :query

      response "200", "get until top 10 rated post without N query params" do
        let!(:post1) { create(:post) }
        let!(:post2) { create(:post) }
        let!(:post3) { create(:post) }
        let!(:rating1) { create(:rating, post: post1, value: 5) }
        let!(:rating2) { create(:rating, post: post2, value: 4) }
        let!(:rating3) { create(:rating, post: post3, value: 3) }
        let(:N) { nil }

        schema "$ref": "#/components/schemas/RenderTopNRatedPosts"

        run_test!
      end

      response "200", "get top rated posts by until 'N' query params" do
        let!(:post1) { create(:post) }
        let!(:post2) { create(:post) }
        let!(:post3) { create(:post) }
        let!(:rating1) { create(:rating, post: post1, value: 5) }
        let!(:rating2) { create(:rating, post: post2, value: 4) }
        let!(:rating3) { create(:rating, post: post3, value: 3) }
        let!(:N) { rand(1..10) }

        schema "$ref": "#/components/schemas/RenderTopNRatedPosts"

        run_test!
      end
    end
  end

  path "/api/v1/posts/authors_ips" do
    get "get authors ips" do
      tags "Post"
      produces "application/json"

      response "200", "get authors ips" do
        let!(:user1) { create(:user) }
        let!(:user2) { create(:user) }
        let!(:post1) { create(:post, user: user1, ip: "192.168.0.1") }
        let!(:post2) { create(:post, user: user2, ip: "192.168.0.1") }
        let!(:post3) { create(:post, user: user1, ip: "192.168.0.2") }

        schema "$ref": "#/components/schemas/RenderAuthorsIps"

        run_test!
      end
    end
  end
end
