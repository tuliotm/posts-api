# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Post, type: :model) do
  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:ip) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:ratings) }
  end

  describe ".user_post" do
    context "when user is found or created" do
      let(:params) { { user_login: "testuser", title: "Test Post", body: "This is a test post", ip: "127.0.0.1" } }

      it "creates a new post associated with the user" do
        expect do
          Post.user_post(params)
        end.to(change(Post, :count).by(1))

        post = Post.last
        expect(post.title).to(eq("Test Post"))
        expect(post.body).to(eq("This is a test post"))
        expect(post.ip).to(eq("127.0.0.1"))
        expect(post.user.login).to(eq("testuser"))
      end
    end

    context "when user is not persisted" do
      let(:params) do
        { title: "Test Post", body: "This is a test post" }
      end

      it "does not create a new post" do
        expect do
          Post.user_post(params)
        end.not_to(change(Post, :count))

        expect(Post.user_post(params)).to(be_nil)
      end
    end
  end

  describe ".top_rated" do
    let!(:post1) { create(:post) }
    let!(:post2) { create(:post) }
    let!(:rating1) { create(:rating, post: post1, value: 5) }
    let!(:rating2) { create(:rating, post: post1, value: 4) }
    let!(:rating3) { create(:rating, post: post2, value: 3) }

    it "returns the posts with the highest average ratings" do
      top_rated = Post.top_rated(1)
      expect(top_rated.length).to(eq(1))
      expect(top_rated.first).to(eq(post1))
    end
  end

  describe ".authors_ips" do
    let!(:user1) { create(:user, login: "user1") }
    let!(:user2) { create(:user, login: "user2") }
    let!(:post1) { create(:post, user: user1, ip: "127.0.0.1") }
    let!(:post2) { create(:post, user: user2, ip: "127.0.0.1") }
    let!(:post3) { create(:post, user: user1, ip: "192.168.0.1") }

    it "returns the IPs that are used by multiple authors" do
      authors_ips = Post.authors_ips
      expect(authors_ips.length).to(eq(1))
      expect(authors_ips.first[:ip]).to(eq("127.0.0.1"))
      expect(authors_ips.first[:authors]).to(contain_exactly("user1", "user2"))
    end
  end
end
