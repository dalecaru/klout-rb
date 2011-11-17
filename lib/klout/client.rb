require 'forwardable'
require 'hashie/mash'
require 'httpi'
require 'multi_json'
require 'rack/utils'
require 'singleton'

module Klout
  class Error < StandardError; end
  class Error::Forbidden < Klout::Error; end
  class Error::GatewayTimeout < Klout::Error; end
  class Error::InternalServerError < Klout::Error; end
  class Error::ServiceUnavailable < Klout::Error; end

  # Public: Class with the necessary methods for performing all Klout API operations.
  # All API methods are instance methods but can be called on the Client class.
  class Client
    include Singleton
    extend SingleForwardable
  
    # Public: Gets/Sets the Klout API key.
    attr_accessor :api_key

    # Public: Gets/Sets an optional Proxy host to use.
    attr_accessor :proxy

    # Internal: Delegates api methods to the Klout::Client instance.
    def_delegators :instance, :score, :profile, :topics, :influenced_by, :influencer_of

    # Public: Configure Klout Client options.
    #
    # Yields the Klout::Client instance.
    #
    # Returns nothing.
    def self.configure
      yield instance if block_given?
    end

    # Public: Klout REST API endpoint
    #
    # Returns the Klout REST API endpoint
    def self.endpoint
      'http://api.klout.com'
    end

    # Public: Retrieve Klout score for the given usernames.
    # 
    # usernames - The username or Array of usernames to look for.
    #
    # Returns an Array of user klout score objects.
    def score(usernames)
      get("/1/klout.json", :users => [usernames].flatten).users
    end

    # Public: Retrieve users Klout profile for the given usernames.
    # 
    # usernames - The username or Array of usernames to look for.
    #
    # Returns an Array of user klout profile objects.
    def profile(usernames)
      get("/1/users/show.json", :users => [usernames].flatten).users
    end

    # Public: Retrieve users topics for the given usernames.
    # 
    # usernames - The username or Array of usernames to look for.
    #
    # Returns an Array of user klout topics objects.
    def topics(usernames)
      get("/1/users/topics.json", :users => [usernames].flatten).users
    end

    # Public: Retrieve users influencers for the given usernames.
    # 
    # usernames - The username or Array of usernames to look for.
    #
    # Returns an Array of klout users with their corresponding influencers.
    def influenced_by(usernames)
      get("/1/soi/influenced_by.json", :users => [usernames].flatten).users
    end

    # Public: Retrieve users influencees for the given usernames.
    # 
    # usernames - The username or Array of usernames to look for.
    #
    # Returns an Array of klout users with their corresponding influencees.
    def influencer_of(usernames)
      get("/1/soi/influencer_of.json", :users => [usernames].flatten).users
    end

    private
    # Internal: Executes a GET HTTP request.
    # 
    # path   - The path to make the request again.
    # params - A Hash with the optionals http params.
    #
    # Returns a response object.
    def get(path, params = {})
      request = HTTPI::Request.new(build_url(path, params))
      request.proxy = proxy unless proxy.nil?
      parse_response(HTTPI.get(request))
    end

    # Internal: Parses the HTTP response.
    #
    # Returns a Mash of the JSON parsed hash.
    # Raises Klout::Error::Forbidden if Klout api key is not valid.
    # Raises Klout::Error::InternalServerError if there is a server error in Klout.
    # Raises Klout::Error::ServiceUnavailable if Klout endpoint is unavailable.
    # Raises Klout::Error::GatewayTimeout if Klout endpoint respond with timeout.
    # Raises Klout::Error for a non 200 response code.
    def parse_response(response)
      case response.code.to_i
      when 200
        body = ::MultiJson.decode(response.body)
        raise Klout::Error.new(body['body']['error']) if body.has_key?('body') && body['body'].has_key?('error')
        Hashie::Mash.new(body)
      when 403
        raise Klout::Error::Forbidden.new
      when 500
        raise Klout::Error::InternalServerError.new
      when 503
        raise Klout::Error::ServiceUnavailable.new
      when 504
        raise Klout::Error::GatewayTimeout.new
      else
        raise Klout::Error.new("#{response.code} - #{response.headers['X-Mashery-Error-Code']}")
      end
    end

    # Internal: Builds the request url.
    #
    # path   - The path to make the request again.
    # params - A Hash with the optionals http params.
    #
    # Returns a string url.
    def build_url(path, params = {})
      "#{self.class.endpoint}#{path}?#{Rack::Utils.build_query(params.merge(:key => api_key.to_s))}"
    end
  end

  HTTPI.log = false
end
