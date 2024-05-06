# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "API V1",
        version: "v1",
      },
      paths: {},
      servers: [
        {
          url: "{defaultHost}",
          variables: {
            defaultHost: {
              default: "http://localhost:3000",
            },
          },
        },
      ],
      components: {
        securitySchemes: {
          "X-TOKEN" => {
            type: :apiKey,
            name: "X-TOKEN",
            in: :header,
          },
        },
        schemas: {
          CreateNewPost: {
            "type": "object",
            "required": [],
            "properties": {
              "post": {
                "type": "object",
                "required": [],
                "properties": {
                  "title": {
                    "type": "string",
                  },
                  "body": {
                    "type": "string",
                  },
                  "user_login": {
                    "type": "string",
                  },
                },
              },
            },
          },
          ####################
          RenderNewPost: {
            "type": "object",
            "required": [],
            "properties": {
              "data": {
                "type": "object",
                "required": [],
                "properties": {
                  "id": {
                    "type": "string",
                  },
                  "type": {
                    "type": "string",
                  },
                  "attributes": {
                    "type": "object",
                    "required": [],
                    "properties": {
                      "id": {
                        "type": "number",
                      },
                      "title": {
                        "type": "string",
                      },
                      "body": {
                        "type": "string",
                      },
                      "ip": {
                        "type": "string",
                      },
                    },
                  },
                  "relationships": {
                    "type": "object",
                    "required": [],
                    "properties": {
                      "user": {
                        "type": "object",
                        "required": [],
                        "properties": {
                          "data": {
                            "type": "object",
                            "required": [],
                            "properties": {
                              "id": {
                                "type": "string",
                              },
                              "type": {
                                "type": "string",
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
          ####################
          ErrorsMessages: {
            "type": "object",
            "required": [],
            "properties": {
              "errors": {
                "type": "array",
                "items": {
                  "type": "string",
                },
              },
            },
          },
          ####################
          CreateNewRating: {
            "type": "object",
            "required": [],
            "properties": {
              "rating": {
                "type": "object",
                "required": [],
                "properties": {
                  "user_id": {
                    "type": "number",
                  },
                  "post_id": {
                    "type": "number",
                  },
                  "value": {
                    "type": "number",
                  },
                },
              },
            },
          },
          ####################
          RenderNewRating: {
            "type": "object",
            "required": [],
            "properties": {
              "average": {
                "type": "string",
              },
              "post_id": {
                "type": "number",
              },
            },
          },
        },
      },
    },
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
