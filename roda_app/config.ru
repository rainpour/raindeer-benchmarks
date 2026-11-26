# frozen_string_literal: true

require File.expand_path('../route_shape', Dir.pwd)

require 'roda'

class App < Roda
  # The route table from route_shape.rb (1000 routes by default) as a tree of segments. r.on -- Roda's routing-tree
  # primitive -- means a failed segment match skips every route nested under it, instead of checking each one.
  # A :param segment matches any one segment with Roda's String matcher.
  #
  # Ordering matters: the route block runs top to bottom on every request, so segments with children (fail fast --
  # one mismatch skips the whole subtree) are checked before plain leaves. Checking them the other way around made
  # every nested request pay for hundreds of wasted leaf checks first -- measured at a 3.5x throughput cost for no
  # benefit to the leaf case, which pays roughly the same either way.

  # Each node as [matcher, route?, children], ordered once at boot.
  def self.prepare(children)
    ordered = children.sort_by.with_index { |(_segment, node), index| [node[:children].empty? ? 1 : 0, index] }

    ordered.map do |segment, node|
      [segment.start_with?(':') ? String : segment, node[:route], prepare(node[:children])]
    end
  end

  ROUTE_TREE = prepare(RouteShape.tree[:children]).freeze

  def route_tree(r, nodes)
    nodes.each do |matcher, route, children|
      if children.empty?
        r.get(matcher) { |*| "Route\n" }
      else
        r.on(matcher) do |*|
          r.get(true) { "Route\n" } if route
          route_tree(r, children)
          nil # Unmatched below here, so a 404 rather than the Array the loop above returns.
        end
      end
    end
  end

  route do |r|
    r.root do
      "Welcome to Roda\n"
    end

    r.get 'slow' do
      sleep(0.05) # Simulates a blocking downstream I/O call (DB query, HTTP request, etc).
      "Slow response\n"
    end

    route_tree(r, ROUTE_TREE)

    nil # the route block's return value is the fallback response body for any unmatched request.
  end
end

run App.freeze.app
