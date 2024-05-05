# frozen_string_literal: true

class AuthorsIpsSerializer
  include JSONAPI::Serializer
  attributes :ip, :authors

  def authors
    object[:authors]
  end
end
