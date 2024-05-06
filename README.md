# Posts API Project

Project developed for users to create posts and rate them.

## Environment Setup

Make sure you have the following versions installed:

- Ruby: 3.3.1
- Rails: 7.1.3.2
- Bundler: 2.5.10

## Installation

Follow the steps below to set up the project on your local machine:

## Clone the repository:

```bash
git clone git@github.com:tuliotm/posts-api.git
cd PostsApi
```

## Install project dependencies:
```bash
bundle install
```

## Create the database and run the migrations:
```bash
rails db:create
rails db:migrate
```

## Start the server:
```bash
rails server
```

## Run the seeds to populate the database (caution! 200,000 posts are prepared to be generated):
```bash
rails db:seed
```

## Access project documentation
[Swagger API Docs](http://localhost:3000/api-docs/index.html)

**To generate new documentation**
```bash
rails rswag:specs:swaggerize PATTERN="spec/swagger/**/*_spec.rb"
```