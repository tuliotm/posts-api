# frozen_string_literal: true

require "rails_helper"

RSpec.describe(User, type: :model) do
  subject(:user) { build :user }

  describe "validations" do
    it { should validate_presence_of(:login) }
    it { should validate_uniqueness_of(:login) }
  end

  describe "associations" do
    it { should have_many(:posts) }
    it { should have_many(:ratings) }
  end
end
