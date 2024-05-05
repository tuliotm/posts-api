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
end
