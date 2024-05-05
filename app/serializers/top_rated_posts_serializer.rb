# frozen_string_literal: true

class TopRatedPostsSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :body
end
