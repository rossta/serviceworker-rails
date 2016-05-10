source "https://rubygems.org"

# Specify your gem's dependencies in serviceworker-rails.gemspec
gemspec

group :development, :test do
  gem "rubocop", "0.39.0"

  unless ENV["TRAVIS"]
    gem "pry"
    gem "pry-byebug", platforms: [:mri]
    gem "guard"
    gem "guard-minitest"
  end
end
