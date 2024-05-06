# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Rating, type: :model) do
  subject(:rating) { build :rating }

  describe "validations" do
    it { should validate_presence_of(:value) }
    it { should validate_inclusion_of(:value).in_range(1..5) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:post_id) }
  end

  describe "associations" do
    it { should belong_to(:post) }
    it { should belong_to(:user) }
  end

  describe ".create_and_calculate_average" do
    let(:post) { create(:post) }
    let(:params) do
      {
        user_id: post.user.id,
        post_id: post.id,
        value: 5,
      }
    end

    context "when the post is not found" do
      it "returns status :not_found and an error message" do
        params[:post_id] = -1
        result = Rating.create_and_calculate_average(params)
        expect(result[:status]).to(eq(:not_found))
        expect(result[:errors]).to(include("Post not found."))
      end
    end

    context "when the post has already been rated by the user" do
      before do
        create(:rating, user: post.user, post: post)
      end

      it "returns status :unprocessable_entity and an error message" do
        result = Rating.create_and_calculate_average(params)
        expect(result[:status]).to(eq(:unprocessable_entity))
        expect(result[:errors]).to(include("Post already rated."))
      end
    end

    context "when the rating is successfully created" do
      it "creates a new rating" do
        expect { Rating.create_and_calculate_average(params) }.to(change { Rating.count }.by(1))
      end

      it "returns status :created and the average rating" do
        result = Rating.create_and_calculate_average(params)
        expect(result[:status]).to(eq(:created))
        expect(result[:average]).to(eq(5.0))
      end
    end

    context "when the rating creation fails" do
      before do
        params[:value] = 6
      end

      it "does not create a new rating" do
        expect { Rating.create_and_calculate_average(params) }.not_to(change { Rating.count })
      end

      it "returns status :unprocessable_entity and error messages" do
        result = Rating.create_and_calculate_average(params)
        expect(result[:status]).to(eq(:unprocessable_entity))
        expect(result[:errors]).to(include("Value is not included in the list"))
      end
    end
  end
end
