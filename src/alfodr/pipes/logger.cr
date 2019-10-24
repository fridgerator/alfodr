module Alfodr
  module Pipe
    class Logger < Base
      alias Params = Array(String)
      Colorize.enabled = ENV["ALFODR_COLORIZE"]? == "true" || true
      FILTERED_TEXT = "FILTERED".colorize(:white).mode(:underline)

      @filter : Params
      @skip : Params
      @context : Params

      def initialize
        filter = [] of String
        if log_filter_env = ENV["ALFODR_LOG_FILTER"]?
          filter = log_filter_env.split(' ')
        end

        skip = [] of String
        if log_skip_env = ENV["ALFODR_LOG_SKIP"]?
          skip = log_skip_env.split(' ')
        end

        context = %w(request headers params)
        if log_context_env = ENV["ALFODR_LOG_CONTEXT"]?
          context = log_context_env.split(' ')
        end

        @filter = filter
        @skip = skip
        @context = context
      end

      def call(context : HTTP::Server::Context)
        time = Time.utc
        call_next(context)
        status = context.response.status_code
        elapsed = elapsed_text(Time.utc - time)
        request(context, time, elapsed, status, :magenta) if @context.includes? "request"
        log_other(context.request.headers, "Headers") if @context.includes? "headers"
        log_other(context.params, "Params", :light_blue) if @context.includes? "params"
        context
      end

      private def request(context, time, elapsed, status, color = :magenta)
        msg = String.build do |str|
          str << "Status: #{http_status(status)} Method: #{method(context)}"
          str << " Pipeline: #{context.valve.colorize(color)} Format: #{context.format.colorize(color)}"
        end
        log "Started #{time.colorize(color)}", "Request", color
        log msg, "Request", color
        log "Requested Url: #{context.requested_url.colorize(color)}", "Request", color
        log "Time Elapsed: #{elapsed.colorize(color)}", "Request", color
      end

      private def log_other(other, name, color = :light_cyan)
        other.to_h.each do |key, val|
          next if @skip.includes? key
          if @filter.includes? key.to_s
            log "#{key}: #{FILTERED_TEXT}", name, color
          else
            log "#{key}: #{val.colorize(color)}", name, color
          end
        end
      end

      private def method(context)
        context.request.method.colorize(:light_red).to_s + " "
      end

      private def http_status(status)
        case status
        when 200..299 then status.colorize(:green)
        when 300..399 then status.colorize(:blue)
        when 400..499 then status.colorize(:yellow)
        when 500..599 then status.colorize(:red)
        else
          status.colorize(:white)
        end
      end

      private def elapsed_text(elapsed)
        millis = elapsed.total_milliseconds
        return "#{millis.round(2)}ms" if millis >= 1
        "#{(millis * 1000).round(2)}µs"
      end

      private def log(msg, prog, color = :white)
        Alfodr.logger.info msg, prog, color
      end
    end
  end
end
