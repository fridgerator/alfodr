require "http"
require "logger"
require "json"
require "colorize"
require "random/secure"

require "./alfodr/version"
require "./alfodr/controller/**"
require "./alfodr/dsl/**"
require "./alfodr/exceptions/**"
require "./alfodr/extensions/**"
require "./alfodr/router/context"
require "./alfodr/pipes/**"
require "./alfodr/server/**"
require "./alfodr/validators/**"
require "./alfodr/websockets/**"
require "./alfodr/environment/**"

# TODO: Write documentation for `Alfodr`
module Alfodr
  def self.logger
    Alfodr::Environment::Logger.new(STDOUT)
  end

  def self.environment
    ENV["ALFODR_ENV"]? || "development"
  end
end
