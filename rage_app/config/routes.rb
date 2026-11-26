# frozen_string_literal: true

require File.expand_path('../route_shape', Dir.pwd)

Rage.routes.draw do
  root to: ->(_env) { [200, {}, ["Welcome to Rage\n"]] }

  get 'slow', to: lambda { |_env|
    sleep(0.05) # Simulates a blocking downstream I/O call (DB query, HTTP request, etc).
    [200, {}, ["Slow response\n"]]
  }

  # The route table from route_shape.rb (1000 routes by default), registered as flat, full path strings rather than
  # via `scope`, since Rage's router is a radix tree (based on find-my-way) regardless of whether the DSL used a flat
  # loop or `scope` nesting (confirmed by reading the gem's source).
  RouteShape.paths.each do |path|
    get path.delete_prefix('/'), to: ->(_env) { [200, {}, ["Route\n"]] }
  end
end
