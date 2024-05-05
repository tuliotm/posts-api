# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Api::V1::Posts", type: :request) do
  describe "POST /create" do
    context "success" do
      let(:user) { create(:user) }
      let(:post_attributes) do
        {
          "post": {
            "title": FFaker::Lorem.sentence,
            "body": FFaker::Lorem.paragraph,
            "ip": FFaker::Internet.ip_v4_address,
            "user_login": user.login,
          },
        }
      end

      before do
        post api_v1_posts_path, params: post_attributes
      end

      it "returns status code created" do
        expect(response).to(have_http_status(:created))
      end
    end

    context "failure" do
      let(:invalid_attributes) do
        {
          "post": {
            "title": FFaker::Lorem.sentence,
            "body": FFaker::Lorem.paragraph,
            "ip": FFaker::Internet.ip_v4_address,
          },
        }
      end

      before do
        post api_v1_posts_path, params: invalid_attributes
      end

      it "returns status code unprocessable_entity" do
        expect(response).to(have_http_status(:unprocessable_entity))
      end
    end
  end

  describe "GET /top_rated" do
    let!(:post1) { create(:post) }
    let!(:post2) { create(:post) }
    let!(:post3) { create(:post) }
    let!(:rating1) { create(:rating, post: post1, value: 5) }
    let!(:rating2) { create(:rating, post: post2, value: 4) }
    let!(:rating3) { create(:rating, post: post3, value: 3) }

    before do
      get "/api/v1/posts/top_rated", params: { N: 2 }
    end

    it "returns status code 200" do
      expect(response).to(have_http_status(:ok))
    end

    it "returns the top N rated posts" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response.size).to(eq(2))
      expect(parsed_response[0]["id"]).to(eq(post1.id))
      expect(parsed_response[1]["id"]).to(eq(post2.id))
    end
  end
end
