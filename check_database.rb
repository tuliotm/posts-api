# frozen_string_literal: true

require_relative "config/environment"

# Check duplicates in Rating model using Active Record
duplicate_ratings = Rating
  .group(:user_id, :post_id)
  .having("COUNT(*) > 1")
  .count

# View the results
if duplicate_ratings.empty?
  puts "No duplicates found. Data integrity is maintained!"
else
  puts "Duplicates detected!"
  duplicate_ratings.each do |key, count|
    user_id, post_id = key
    puts "User ID: #{user_id}, Post ID: #{post_id}, Count: #{count}"
  end
end
