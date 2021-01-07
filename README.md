# ServiceWorker::Rails

[![Build Status](https://travis-ci.org/rossta/serviceworker-rails.svg?branch=master)](https://travis-ci.org/rossta/serviceworker-rails)
[![Code Climate](https://codeclimate.com/github/rossta/serviceworker-rails/badges/gpa.svg)](https://codeclimate.com/github/rossta/serviceworker-rails)

Turn your Rails app into a Progressive Web App. Use [Service Worker](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) with the Rails [asset pipeline](https://github.com/rails/sprockets-rails) or [Webpacker](https://github.com/rails/webpacker)

## Why?

The Rails asset pipeline makes a number of assumptions about what's best for deploying JavaScript, including asset digest fingerprints and long-lived cache headers - mostly to increase "cacheability". Rails also assumes a single parent directory, `/public/assets`, to make it easier to look up the file path for a given asset.

Service worker assets must play by different rules. Consider these behaviors:

* Service workers may only be active from within the scope from which they are
served. So if you try to register a service worker from a Rails asset pipeline
path, like `/assets/serviceworker-abcd1234.js`, it will only be able to interact
with requests and responses within `/assets/`<em>**</em>. This is not what we want.

* [MDN states](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API#Download_install_and_activate) browsers check for updated service worker scripts in the background every 24 hours (possibly less). Rails developers wouldn't be able to take advantage of this feature since the fingerprint strategy means assets at a given url are immutable. Beside fingerprintings, the `Cache-Control` headers used for static files served from Rails also work against browser's treatment of service workers.

We want Sprockets or Webpacker to compile service worker JavaScript from ES6/7, CoffeeScript, ERB, etc. but must remove the caching and scoping mechanisms offered by Rails defaults. This is where `serviceworker-rails` comes in.

*Check out the [blog post](https://rossta.net/blog/service-worker-on-rails.html)
for more background.*

### Demo

See various examples of using Service Workers in the demo Rails app, [Service Worker Rails Sandbox](https://serviceworker-rails.herokuapp.com/). The [source code](https://github.com/rossta/serviceworker-rails-sandbox) is also on GitHub.

## Features

* Maps service worker endpoints to Rails assets
* Adds appropriate response headers to service workers
* Renders compiled source in production and development

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'serviceworker-rails'
```

And then execute:

```bash
    bundle
```

Or install it yourself as:

```bash
    gem install serviceworker-rails
```

To set up your Rails project for use with a Service Worker, you either use the
Rails generator and edit the generated files as needed, or you can follow the
manual installation steps.

### Automated setup

After bundling the gem in your Rails project, run the generator from the root of
your Rails project.
The generator generates service-worker for the Sprockets asset pipeline by default.
To generate service-worker for the Webpakcer asset pipeline the "--webpacker" flag shall be added.
It's *recommended* to use the automated setup which takes care for the specific asset pipeline used by your app, and modify the files being generated.

```bash
rails g serviceworker:install # for Sprockets asset pipeline
rails g serviceworker:install --webpacker # for Webpacker asset pipeline
```

The generator will create the following files:

* `config/initializers/serviceworker.rb` - for configuring your Rails app
* `app/assets/javascripts/serviceworker.js.erb` - a blank Service Worker
  script with some example strategies
* `app/assets/javascripts/serviceworker-companion.js` - a snippet of JavaScript
  necessary to register your Service Worker in the browser
* `app/assets/javascripts/manifest.json.erb` - a starter web app manifest
  pointing to some default app icons provided by the gem
* `public/offline.html` - a starter offline page

It will also make the following modifications to existing files:

* Adds a sprockets directive/webpacker require to `application.js` to require
  `serviceworker-companion.js`
* Adds `serviceworker.js` and `manifest.json` to the list of compiled assets in
  `config/initializers/assets.rb`
* Injects tags into the `head` of `app/views/layouts/application.html.erb` for
  linking to the web app manifest

**NOTE** Given that Service Worker operates in a separate browser thread, outside the context of your web pages, you don't want to include `serviceworker.js` script in your `application.js`. So if you have a line like `require_tree .` in your `application.js` file, you'll either need to move your `serviceworker.js` to another location or replace `require_tree` with something more explicit.

To learn more about each of the changes or to perform the set up yourself, check
out the manual setup section below.

### Manual setup

Let's add a `ServiceWorker` to cache some of your JavaScript and CSS assets.
The following assumes that you have a Rails application **using the sprockets asset pipeline**.

#### Add a service worker script

Create a JavaScript file called `app/assets/javascripts/serviceworker.js.erb`:

```javascript
// app/assets/javascripts/serviceworker.js.erb
console.log('[Service Worker] Hello world!');

var CACHE_VERSION = 'v1';
var CACHE_NAME = CACHE_VERSION + ':sw-cache-';

function onInstall(event) {
  console.log('[Serviceworker]', "Rails Service Worker Installing!", event);
  event.waitUntil(
    caches.open(CACHE_NAME).then(function prefill(cache) {
      return cache.addAll([

        // make sure serviceworker.js is not required by application.js
        // if you want to reference application.js from here
        // (Change accordingly when Webpacker serves js/css).
        '<%= asset_path "application.js" %>',
        '<%= asset_path "application.css" %>',
        '/offline.html',
        // you get the idea ...
      ]);
    })
  );
}

function onActivate(event) {
  console.log('[Serviceworker]', "Rails Service Worker Activating!", event);
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.filter(function(cacheName) {
          // Return true if you want to remove this cache,
          // but remember that caches are shared across
          // the whole origin
          return cacheName.indexOf(CACHE_VERSION) !== 0;
        }).map(function(cacheName) {
          return caches.delete(cacheName);
        })
      );
    })
  );
}

// Borrowed from https://github.com/TalAter/UpUp
function onFetch(event) {
  event.respondWith(
    // try to return untouched request from network first
    fetch(event.request).catch(function() {
      // if it fails, try to return request from the cache
      return caches.match(event.request).then(function(response) {
        if (response) {
          return response;
        }
        // if not found in cache, return default offline content for navigate requests
        if (event.request.mode === 'navigate' ||
          (event.request.method === 'GET' && event.request.headers.get('accept').includes('text/html'))) {
          console.log('[Serviceworker]', "Rails Service Worker Fetching offline content", event);
          return caches.match('/offline.html');
        }
      })
    })
  );
}

self.addEventListener('install', onInstall);
self.addEventListener('activate', onActivate);
self.addEventListener('fetch', onFetch);
```

For use in production, instruct Sprockets to precompile service worker scripts separately from `application.js`, as in the following example:

#### Register the service worker

You'll need to register the service worker with a companion script in your main page JavaScript, like `application.js`. You can use the following:

```javascript
// app/assets/javascripts/serviceworker-companion.js

if (navigator.serviceWorker) {
  navigator.serviceWorker
    .register("/serviceworker.js", { scope: "./" })
      .then(function() {
        console.log("[Companion]", "Rails Service worker registered!")
      })
      .catch(function(error) {
       // registration failed :(
        console.log("[Companion]", "Rails Service worker registration failed: " + error)
      })
}

// app/assets/javascripts/application.js

// ...
//= require serviceworker-companion
```

#### Add a manifest

You may also want to create a `manifest.json` file to make your web app installable.

```javascript
// app/assets/javascripts/manifest.json
{
  "name": "My Progressive Rails App",
  "short_name": "Progressive",
  "start_url": "/",
  "theme_color": "#000000",
  "background_color": "#FFFFFF",
  "display": "fullscreen",
  "orientation": "portrait"
}
```

You'd then link to your manifest from the application layout:

```html
<link rel="manifest" href="/manifest.json" />
<meta name="apple-mobile-web-app-capable" content="yes">
```

#### Configure the middleware

Next, add a new initializer as show below to instruct the `serviceworker-rails`
middleware how to route requests for assets by canonical url.

```ruby
# config/initializers/serviceworker.rb

Rails.application.configure do
  config.serviceworker.routes.draw do
    match "/serviceworker.js"
    match "/manifest.json"
  end
end
```

#### Precompile the assets

```ruby
# config/initializers/assets.rb

Rails.application.configure do
  config.assets.precompile += %w[serviceworker.js manifest.json]
end
```

#### Test the setup

At this point, restart your Rails app and reload a page in your app in Chrome or Firefox. Using dev tools, you should be able to determine.

1. The page requests a service worker at `/serviceworker.js`
2. The Rails app responds to the request by compiling and rendering the file in `app/assets/javascripts/serviceworker.js.erb`.
3. The console displays messages from the page and the service worker
4. The application JavaScript and CSS assets are added to the browser's request/response [Cache](https://developer.mozilla.org/en-US/docs/Web/API/Cache).

#### Using the cache

So far so good? At this point, all we've done is pre-fetched assets and added them to the cache, but we're not doing anything with them yet.

Now, we can use the service worker to intercept requests and either serve them from the cache if they exist there or fallback to the network response otherwise. In most cases, we can expect responses coming from the local cache to be much faster than those coming from the network.

```javascript
// app/assets/javascripts/serviceworker.js.erb

function onFetch(event) {
  // Fetch from network, fallback to cached content, then offline.html for same-origin GET requests
  var request = event.request;

  if (!request.url.match(/^https?:\/\/example.com/) ) { return; }
  if (request.method !== 'GET') { return; }

  event.respondWith(
    fetch(request)                                        // first, the network
      .catch(function fallback() {
         caches.match(request).then(function(response) {  // then, the cache
           response || caches.match("/offline.html");     // then, /offline cache
         })
       })
  );

  // See https://jakearchibald.com/2014/offline-cookbook/#on-network-response for more examples
}

self.addEventListener('fetch', onFetch);
```

#### Integration with Webpacker notes

The automated install script takes care for the initial scaffold for using the serviceworker with Webpacker.

Depending on which loaders you use, Webpacker may not serve the manifest.json.erb correctly.
Our suggestion is to create a manifest.json and put it under the public/ directory instead of being served from Webpacker.

## Configuration

When `serviceworker-rails` is required in your Gemfile, it will insert a middleware into the Rails
middleware stack. You'll want to configure it by mapping serviceworker routes to
Sprockets JavaScript assets in an initializer, like the example below.

```ruby
# config/initializers/serviceworker.rb

Rails.application.configure do
  config.serviceworker.routes.draw do
    # maps to asset named 'serviceworker.js' implicitly
    match "/serviceworker.js"

    # map to a named asset explicitly
    match "/proxied-serviceworker.js" => "nested/asset/serviceworker.js"
    match "/nested/serviceworker.js" => "another/serviceworker.js"

    # capture named path segments and interpolate to asset name
    match "/captures/*segments/serviceworker.js" => "%{segments}/serviceworker.js"

    # capture named parameter and interpolate to asset name
    match "/parameter/:id/serviceworker.js" => "project/%{id}/serviceworker.js"

    # insert custom headers
    match "/header-serviceworker.js" => "another/serviceworker.js",
      headers: { "X-Resource-Header" => "A resource" }

    # maps to serviceworker "pack" compiled by Webpacker
    match "/webpack-serviceworker.js" => "serviceworker.js", pack: true

    # anonymous glob exposes `paths` variable for interpolation
    match "/*/serviceworker.js" => "%{paths}/serviceworker.js"
  end
end
```

`Serviceworker::Rails` will insert a `Cache-Control` header to instruct browsers
not to cache your serviceworkers by default. You can customize the headers for all service worker routes if you'd like,
such as adding the experimental [`Service-Worker-Allowed`](https://slightlyoff.github.io/ServiceWorker/spec/service_worker/#service-worker-allowed) header to set the allowed scope.

```ruby
config.serviceworker.headers["Service-Worker-Allowed"] = "/"
config.serviceworker.headers["X-Custom-Header"] = "foobar"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

To run tests use:

```ruby
bundle exec appraisal bundle install
bundle exec appraisal rake test
```

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

A Dockerfile is provided with two stages "development" and "testing":

```bash
docker build --target development -t service_worker:1.0 .
docker build --target testing -t service_worker:1.0 . # to run tests in build
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/rossta/serviceworker-rails>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
