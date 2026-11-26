# frozen_string_literal: true

require File.expand_path('../route_shape', Dir.pwd)

class RouteNNode < LowNode
  RouteShape.paths.each { |path| observe path }

  def render
    "Route\n"
  end
end
