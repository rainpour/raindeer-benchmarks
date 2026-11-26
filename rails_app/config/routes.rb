require File.expand_path('../route_shape', Dir.pwd)

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "home#show"
  get "/slow" => "home#slow"

  # The route table from route_shape.rb (1000 routes by default), registered as flat, full path strings rather than
  # via `scope`, since Rails' Journey router compiles every route into one shared DFA regardless of whether the DSL
  # used a flat loop or `scope` nesting (confirmed by reading actionpack's source).
  RouteShape.paths.each { |path| get path => "home#route_n" }
end
