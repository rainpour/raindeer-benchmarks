# frozen_string_literal: true

require File.expand_path("../route_shape", Dir.pwd)

class RouteNNode < LowNode
  RouteShape.plain_solos.each { |s| observe "/solo#{s}" }
  RouteShape.solo_parents.each do |s|
    observe "/solo#{s}"
    RouteShape.plain_duos.each { |d| observe "/solo#{s}/duo#{d}" }
    RouteShape.duo_parents.each do |d|
      observe "/solo#{s}/duo#{d}"
      RouteShape.trios.each { |t| observe "/solo#{s}/duo#{d}/trio#{t}" }
    end
  end

  def render
    "Route\n"
  end
end
