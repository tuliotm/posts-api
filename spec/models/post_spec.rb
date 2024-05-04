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
end
