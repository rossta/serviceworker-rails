source "https://rubygems.org"

# Specify your gem's dependencies in serviceworker-rails.gemspec
gemspec

group :development, :test do
  gem "rubocop"
  unless ENV["TRAVIS"]
    gem "pry-byebug", platforms: [:ruby_23]
    gem "guard"
    gem "guard-minitest"
  end
end
