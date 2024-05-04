# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    login { FFaker::Internet.email }
  end
end
