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
            "login": nil,
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

  describe "GET /authors_ips" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:post1) { create(:post, user: user1, ip: "192.168.0.1") }
    let!(:post2) { create(:post, user: user2, ip: "192.168.0.1") }
    let!(:post3) { create(:post, user: user1, ip: "192.168.0.2") }

    before { get("/api/v1/posts/authors_ips") }

    it "returns http success" do
      expect(response).to(have_http_status(:success))
    end

    it "returns correct authors_ips" do
      parsed_response = JSON.parse(response.body)
      expected_authors = [user1.login, user2.login].sort
      expect(parsed_response).to(include(
        { "ip" => "192.168.0.1", "authors" => expected_authors },
      ))
    end

    it "does not return ip with only one author" do
      parsed_response = JSON.parse(response.body)
      expect(parsed_response).not_to(include(
        { "ip" => "192.168.0.2", "authors" => [user1.login] },
      ))
    end
  end
end
