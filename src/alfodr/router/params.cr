require "http"
require "./parsers/*"
require "./file"

module Alfodr::Router
  module Types
    alias Key = String | Symbol
    alias Files = Hash(String, Alfodr::Router::File)
    alias Params = Hash(String, String)
  end

  class Params
    TYPE_EXT_REGEX   = Alfodr::Support::MimeTypes::TYPE_EXT_REGEX
    APPLICATION_JSON = "application/json"

    @files = Types::Files.new
    # @multipart : Types::Params?
    @json : Types::Params?
    # @form : HTTP::Params?

    def initialize(@request : HTTP::Request)
    end

    def [](key : Types::Key) : String
      self.[key]? || raise Alfodr::Exceptions::Validator::InvalidParam.new(key)
    end

    def []?(key : Types::Key)
      _key = key.to_s
      route[_key]? || override_method?(_key) || json[_key]?
    end

    def files
      multipart unless @multipart
      @files
    end

    def []=(key : Types::Key, value)
      query[key.to_s] = value
    end

    def has_key?(key : Types::Key)
      self.[key.to_s]?
    end

    def fetch_all(key : Types::Key) : Array
      _key = key.to_s
      if query.has_key?(_key)
        query.fetch_all(_key)
      else
        form.fetch_all(_key)
      end
    end

    def json(key : Types::Key)
      JSON.parse(self[key]?.to_s)
    rescue JSON::ParseException
      raise "Value of params.json(#{key.inspect}) is not JSON!"
    end

    def override_method?(key : Types::Key)
      query[key]?
    end

    def to_h : Types::Params
      params_hash = Types::Params.new
      query.each { |key, _| params_hash[key] = query[key] }
      route.each_key { |key| params_hash[key] = route[key] }
      json.each_key { |key| params_hash[key] = json[key].to_s }
      params_hash
    end

    private def query
      @request.query_params
    end

    private def json
      return Types::Params.new unless content_type?(APPLICATION_JSON)
      @json ||= Parsers::JSON.parse(@request)
    end

    private def route
      @request.matched_route.params
    end

    private def content_type?(header_type)
      @request.headers["Content-Type"]?.try &.starts_with?(header_type)
    end
  end
end
