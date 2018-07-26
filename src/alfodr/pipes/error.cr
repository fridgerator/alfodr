module Alfodr
  module Pipe
    # The Error pipe catches RouteNotFound and returns a 404. It responds based
    # on the `Accepts` header as JSON or HTML. It also catches any runtime
    # Exceptions and returns a backtrace in text/html format.
    class Error < Base
      def call(context : HTTP::Server::Context)
        raise Alfodr::Exceptions::RouteNotFound.new(context.request) unless context.valid_route?
        call_next(context)
      rescue ex : Alfodr::Exceptions::Forbidden
        context.response.status_code = 403
        error = Alfodr::Controller::Error.new(context, ex)
        context.response.print(error.forbidden)
      rescue ex : Alfodr::Exceptions::RouteNotFound
        context.response.status_code = 404
        error = Alfodr::Controller::Error.new(context, ex)
        context.response.print(error.not_found)
      rescue ex : Exception
        context.response.status_code = 500
        error = Alfodr::Controller::Error.new(context, ex)
        context.response.print(error.internal_server_error)
      end
    end
  end
end
