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

  describe "scope top_rated" do
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
end
