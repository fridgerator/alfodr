require "http"

require "./helpers/*"

module Alfodr::Controller
  class Base
    include Helpers::Route

    protected getter context : HTTP::Server::Context
    protected getter params : Alfodr::Validators::Params

    delegate :logger, to: Alfodr.settings

    delegate :client_ip,
      :delete?,
      :format,
      :get?,
      :halt!,
      :head?,
      :patch?,
      :port,
      :post?,
      :put?,
      :request,
      :requested_url,
      :response,
      :route,
      :valve,
      :websocket?,
      to: context

    def initialize(@context : HTTP::Server::Context)
      @params = Alfodr::Validators::Params.new(context.params)
    end
  end
end
