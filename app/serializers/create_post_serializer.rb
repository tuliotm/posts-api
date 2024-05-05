# frozen_string_literal: true

class CreatePostSerializer
  include JSONAPI::Serializer
  attributes :id, :title, :body, :ip

  belongs_to :user, serializer: UserSerializer
end
