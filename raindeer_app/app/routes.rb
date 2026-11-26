# frozen_string_literal: true

require File.expand_path('../route_shape', Dir.pwd)

Raindeer.router do
  get '/'
  get '/slow'
  get '/template'

  # The route table from route_shape.rb (1000 routes by default), registered as flat, full path strings rather than
  # via `get`'s nested-block form (see route_n_node.rbx for the matching observers), since Raindeer's router is a
  # trie that prefix-shares regardless of DSL nesting -- nesting wouldn't change dispatch cost here either way.
  RouteShape.paths.each { |path| get path }
end
