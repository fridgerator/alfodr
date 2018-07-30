require "http"
require "logger"
require "json"
require "colorize"
require "random/secure"

require "./Alfodr/version"
require "./Alfodr/controller/**"
require "./Alfodr/dsl/**"
require "./Alfodr/exceptions/**"
require "./Alfodr/extensions/**"
require "./Alfodr/router/context"
require "./Alfodr/pipes/**"
require "./Alfodr/server/**"
require "./Alfodr/validators/**"
require "./Alfodr/websockets/**"
require "./Alfodr/environment/**"

# TODO: Write documentation for `Alfodr`
module Alfodr
  def self.logger
    Alfodr::Environment::Logger.new(STDOUT)
  end

  def self.environment
    ENV["ALFODR_ENV"]? || "development"
  end
end
