# frozen_string_literal: true

1000.times do
  FactoryBot.create(:post)
end

BASE_URL = "http://localhost:3000/api/v1"
POST_COUNT = 1000
USER_COUNT = 100
IP_COUNT = 50
RATING_PERCENTAGE = 0.75

USER_COUNT.times do |i|
  FactoryBot.create(:user, login: FFaker::Internet.unique.email)
  Rails.logger.debug("#{i + 1} users created with success")
end

user_logins = User.pluck(:login)

ips = Array.new(IP_COUNT) { FFaker::Internet.unique.ip_v4_address }

post_ids = []

POST_COUNT.times do |i|
  user_login = user_logins.sample
  title = FFaker::Lorem.sentence
  body = FFaker::Lorem.paragraph
  ip = ips[i % IP_COUNT]

  command = <<-CURL
    curl -s -X POST "#{BASE_URL}/posts" \
    -H "Content-Type: application/json" \
    -H "X-Forwarded-For: #{ip}" \
    -d '{"post": {"user_login": "#{user_login}", "title": "#{title}", "body": "#{body}"}}'
  CURL

  response = %x(#{command})
  post_data = begin
    JSON.parse(response)
  rescue
    nil
  end

  if post_data && post_data["data"] && post_data["data"]["id"]
    post_ids << post_data["data"]["id"].to_i
    Rails.logger.debug("#{i + 1} posts created with success")
  end
end

target_posts_count = (POST_COUNT * RATING_PERCENTAGE).to_i
target_posts = post_ids.sample(target_posts_count)

target_posts.each_with_index do |post_id, index|
  user_login = user_logins.sample
  user = User.find_by(login: user_login)
  value = BigDecimal(rand(1.0..5.0), 2).to_f

  command = <<-CURL
    curl -s -o /dev/null -X POST "#{BASE_URL}/ratings" \
    -H "Content-Type: application/json" \
    -d '{"rating": {"post_id": #{post_id}, "user_id": "#{user.id}", "value": #{value.round(2)}}}'
  CURL

  system(command)
  Rails.logger.debug("#{index + 1} ratings created with success")
end
