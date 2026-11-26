# frozen_string_literal: true

# Falcon speaks Protocol::HTTP::Request/Response natively -- and so does Raindeer's
# Router/LowNode/Observer pipeline, once LowLoop is out of the picture (see
# rack_adapter.rb). Falcon's own `falcon serve -c <file>.rb` mode already loads a
# Protocol::HTTP::Middleware app directly (`Protocol::HTTP::Middleware.load`), with
# no Rack involved at all -- that's the counterpart to `.ru` files, which get wrapped
# in `Protocol::Rack::Adapter` (see Falcon::Environment::Serve#middleware). So unlike
# the rack_adapter.rb test, this skips Rack entirely in both directions: no Protocol::HTTP
# -> Rack env -> Protocol::HTTP round trip anywhere in the request path.

# The same LowType config and Raindeer boot as LowLoop's bin/server, so all three Raindeer servers run the same app.
require_relative 'config/boot'

Low::Events::RequestEvent.define do |observers|
  observers << Providers['rain.router']
end

module RaindeerProtocolApp
  def self.call(request)
    if ENV['COUNT_ALLOCS']
      GC.disable
      before = GC.stat(:total_allocated_objects)
      before_types = ObjectSpace.count_objects
      response = Low::Events::RequestEvent.take(request:).response
      after = GC.stat(:total_allocated_objects)
      after_types = ObjectSpace.count_objects
      delta = after_types.each_with_object({}) { |(k, v), h| d = v - (before_types[k] || 0); h[k] = d if d != 0 }
      warn "ALLOCS: #{after - before} #{delta.sort_by { |_, v| -v }.first(8).to_h}"
      return response
    end

    Low::Events::RequestEvent.take(request:).response
  end

  def self.close; end
end
