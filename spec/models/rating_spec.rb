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
end
