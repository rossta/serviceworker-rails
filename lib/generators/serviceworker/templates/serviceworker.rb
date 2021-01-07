# frozen_string_literal: true

Rails.application.configure do
  config.serviceworker.routes.draw do
    # map to assets implicitly
    <% if options[:webpacker] -%>
    match "/serviceworker.js" => 'serviceworker.js', pack: true
    <% else -%>
    match "/serviceworker.js"
    <% end -%>
    match "/manifest.json"

    # Examples
    #
    # map to assets implicitly (default in sprockets)
    #   match "/serviceworker.js"
    #   match "/manifest.json"
    #
    # map to a named asset explicitly
    # match "/proxied-serviceworker.js" => "nested/asset/serviceworker.js"
    # match "/nested/serviceworker.js" => "another/serviceworker.js"
    #
    # capture named path segments and interpolate to asset name
    # match "/captures/*segments/serviceworker.js" => "%{segments}/serviceworker.js"
    #
    # capture named parameter and interpolate to asset name
    # match "/parameter/:id/serviceworker.js" => "project/%{id}/serviceworker.js"
    #
    # insert custom headers
    # match "/header-serviceworker.js" => "another/serviceworker.js",
    #   headers: { "X-Resource-Header" => "A resource" }
    #
    # maps to serviceworker "pack" compiled by Webpacker
    # match "/webpack-serviceworker.js" => "serviceworker.js", pack: true
    #
    # anonymous glob exposes `paths` variable for interpolation
    # match "/*/serviceworker.js" => "%{paths}/serviceworker.js"
  end
end
