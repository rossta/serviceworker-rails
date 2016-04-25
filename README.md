# ServiceWorker::Rails

Integrates ServiceWorker scripts with the Rails asset pipeline.

## Features

* Leverages Rails asset pipeline to compile service worker scripts
* Adds appropriate response headers to service worker scripts
* Renders compiled source in production and development

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serviceworker-rails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install serviceworker-rails

## Usage

To use `serviceworker-rails` in a Rails app, install the gem as above. When
`serviceworker-rails` is required, it will insert a middleware into the Rails
middleware stack. You'll want to configure it by mapping serviceworker routes to
Sprockets JavaScript assets, like the example below, in `application.rb`.

```ruby
# application.rb

config.serviceworker.routes.draw do
  get "/basic-serviceworker.js"

  get "/proxied-serviceworker.js"
    asset: "nested/asset/serviceworker.js"

  get "/nested/serviceworker.js",
    asset: "another/serviceworker.js"

  get "/header-serviceworker.js",
    asset: "another/serviceworker.js",
    headers: { "X-Resource-Header" => "A resource" }

  get "/*/serviceworker.js",
    asset: "serviceworker.js"
end
```

`Serviceworker-Rails` with insert a `Cache-Control` header to instruct browsers
not to cache your serviceworkers by default. You can customize the headers for all service worker routes if you'd like,
such as adding the experimental [`Service-Worker-Allowed`](https://slightlyoff.github.io/ServiceWorker/spec/service_worker/#service-worker-allowed) header to set the allowed scope.

```ruby
config.serviceworker.headers["Service-Worker-Allowed"] = "/"
config.serviceworker.headers["X-Custom-Header"] = "foobar"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/serviceworker-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

