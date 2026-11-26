# frozen_string_literal: true

require File.expand_path('../route_shape', Dir.pwd)

module HanamiApp
  class Routes < Hanami::Routes
    root to: "home.show"
    get "/slow", to: "home.slow"

    # The route table from route_shape.rb (1000 routes by default), registered as flat, full path strings rather than
    # via `scope`, since Hanami::Router is a radix trie (hash lookup per segment) regardless of whether routes are
    # declared flat or via `scope` (confirmed by reading hanami-router's source).
    RouteShape.paths.each { |path| get path, to: "home.route_n" }
  end
end
