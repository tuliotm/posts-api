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
            "user_login": user.login,
          },
        }
      end

      let(:new_user_login) { "new_user" }
      let(:new_post_attributes) do
        {
          "post": {
            "title": FFaker::Lorem.sentence,
            "body": FFaker::Lorem.paragraph,
            "user_login": new_user_login,
          },
        }
      end

      it "returns status code created with a existing user" do
        post api_v1_posts_path, params: post_attributes
        expect(response).to(have_http_status(:created))
      end

      it "creates the user and returns status code created" do
        post api_v1_posts_path, params: new_post_attributes
        expect(User.exists?(login: new_user_login)).to(be(true))
        expect(response).to(have_http_status(:created))
      end

      it "saves the post to the database" do
        post api_v1_posts_path, params: post_attributes
        created_post = Post.find_by(title: post_attributes[:post][:title], user: user)
        expect(created_post).not_to(be_nil)
        expect(created_post.body).to(eq(post_attributes[:post][:body]))
      end

      it "saves the correct IP address" do
        post api_v1_posts_path, params: post_attributes, headers: { "REMOTE_ADDR": "127.0.0.1" }

        created_post = Post.find_by(title: post_attributes[:post][:title], user: user)
        expect(created_post.ip).to(eq("127.0.0.1"))
      end
    end

    context "with missing parameters" do
      it "returns blank title error" do
        post "/api/v1/posts", params: { "post": { body: "", user_login: "user@user.com" } }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to(include(
          "Title can't be blank",
        ))
      end

      it "returns blank body error" do
        post "/api/v1/posts", params: { "post": { title: "", user_login: "user@user.com" } }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to(include(
          "Body can't be blank",
        ))
      end

      it "returns blank title and body error" do
        post "/api/v1/posts", params: { "post": { user_login: "user@user.com" } }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to(include(
          "Title can't be blank",
          "Body can't be blank",
        ))
      end

      it "returns blank user_login error" do
        post "/api/v1/posts", params: { "post": { title: "" } }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to(include(
          "User couldn't be created or persisted",
        ))
      end

      it "returns status code unprocessable_entity" do
        post "/api/v1/posts", params: { "post": { body: "", user_login: "user@user.com" } }
        expect(response).to(have_http_status(:unprocessable_entity))
      end

      it "returns status code bad_request" do
        post "/api/v1/posts"
        expect(response).to(have_http_status(:bad_request))
        expect(response.body).to(include("param is missing or the value is empty: post"))
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
