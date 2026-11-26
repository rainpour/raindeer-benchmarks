# frozen_string_literal: true

require 'bundler/setup'
require 'lowtype'

# Must run before any Raindeer classes load -- LowType rewrites each class's typed methods once, as the class loads.
# Strip mode rewrites them without types, as plain Ruby methods, for close to native speed.
LowType.configure do |config|
  config.type_checking = false
  config.disable_mode = :strip
end

require 'raindeer/boot'

# The bundled Matrix "digital rain" renderer crashes on every request (nil
# screen dimensions reach Rain::Matrix#upsert_stream) and LowLoop's own
# show_output default requires a real TTY to set up. Neither is part of
# routing/response handling, so disable the renderer -- the benchmark then
# measures routing/response only, same as roda_app/hanami_app carry no
# extra middleware either.
Providers.define('rain.matrix') { nil }
