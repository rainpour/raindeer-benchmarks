# frozen_string_literal: true

require File.expand_path('../route_shape', Dir.pwd)

require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    "Welcome to Sinatra\n"
  end

  get '/slow' do
    sleep(0.05) # Simulates a blocking downstream I/O call (DB query, HTTP request, etc).
    "Slow response\n"
  end

  # The route table from route_shape.rb (1000 routes by default), registered as flat, full path strings rather than
  # via Sinatra::Namespace, since nesting there is registration-time string concatenation into the exact same flat,
  # linearly-scanned route list (confirmed by reading sinatra-contrib's source) -- it doesn't help, and measured
  # slightly worse than this, likely from the extra composed-Mustermann-pattern overhead per check.
  RouteShape.paths.each do |path|
    get path do
      "Route\n"
    end
  end
end

run App.new
