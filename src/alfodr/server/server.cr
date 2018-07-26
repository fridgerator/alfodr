require "logger"

module Alfodr
  class Server
    include Alfodr::DSL::Server
    getter handler = Pipe::Pipeline.new
    getter router = Router::Router.new

    def self.instance
      @@instance ||= new
    end

    def self.start
      instance.run
    end

    def self.configure
      with self yield
    end

    def self.router
      instance.router
    end

    def self.handler
      instance.handler
    end

    def run
      thread_count = (ENV["ALFODR_PROCESS_COUNT"]? || 1).to_i
      if Cluster.master? && thread_count > 1
        thread_count.times { Cluster.fork }
        sleep
      else
        start
      end
    end

    def start
      time = Time.now
      logger.info "#{version.colorize(:light_cyan)} serving application on port #{port}"
      handler.prepare_pipelines
      server = HTTP::Server.new(handler)
      server.tls = Alfodr::SSL.new(ENV["ALFODR_SSL_KEY_FILE"], ENV["ALFODR_SSL_CERT_FILE"]).generate_tls if ssl_enabled?

      Signal::INT.trap do
        Signal::INT.reset
        logger.info "Shutting down Alfodr"
        server.close
      end

      loop do
        begin
          logger.info "Server started in #{Alfodr.environment}"
          logger.info "Startup Time #{Time.now - time}".colorize(:white)
          port_reuse = !ENV["ALFODR_PROCESS_COUNT"]?.nil?
          server.listen(port, port_reuse)
          break
        rescue e : Errno
          if e.errno == Errno::EMFILE
            logger.error e.message
            logger.info "Restarting server..."
            sleep 1
          else
            logger.error e.message
            break
          end
        end
      end
    end


    def port
      (ENV["ALFODR_PORT"]? || "3000").to_i
    end

    def version
      "Alfodr 0.1.0"
    end

    def ssl_enabled?
      ENV["ALFODR_SSL_KEY_FILE"]? && ENV["ALFODR_SSL_CERT_FILE"]?
    end

    def scheme
      ssl_enabled? ? "https" : "http"
    end

    def logger
      Alfodr.logger
    end

    # def settings
    #   Alfodr.settings
    # end
  end
end