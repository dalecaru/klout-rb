require 'forwardable'
require 'hashie/mash'
require 'httpi'
require 'multi_json'
require 'rack/utils'
require 'singleton'

module Klout
  class Error < StandardError; end
  class Error::Forbidden < Klout::Error; end
  class Error::InternalServerError < Klout::Error; end
  class Error::ServiceUnavailable < Klout::Error; end

  class Client
    include Singleton
    extend SingleForwardable
  
    attr_accessor :api_key, :proxy

    def_delegators :instance, :score, :profile, :topics, :influenced_by, :influencer_of

    # Configure Klout Client options
    # 
    # == Example
    #
    #  Klout::Client.configure do |config|
    #    config.api_key = <YOUR_API_KEY_HERE>
    #    config.proxy   = "http://example.com"
    #  end
    #
    def self.configure
      yield instance if block_given?
    end

    # Klout REST API endpoint
    def self.endpoint
      'http://api.klout.com'
    end

    # Retrieve Klout score for the given username.
    #
    # @see http://developer.klout.com/docs/read/api/API
    # @param usernames [Array<String>] Twitter usernames.
    # @return [Array<Hashie::Mash>] User Score Pair
    # @example Return the Klout score for damiancaruso
    # Klout::Client.score("damiancaruso")
    def score(usernames)
      get("/1/klout.json", :users => [usernames].flatten).users
    end

    # Retrieve User profile for the given username.
    #
    # @see http://developer.klout.com/docs/read/api/User_Methods
    # @param usernames [Array<String>] Twitter usernames.
    # @return [Array<Hashie::Mash>] User Object
    # @example Return the profile for damiancaruso
    # Klout::Client.profile("damiancaruso")
    def profile(usernames)
      get("/1/users/show.json", :users => [usernames].flatten).users
    end

    # Retrieve User topics for the given username.
    #
    # @see http://developer.klout.com/docs/read/api/User_Methods
    # @param usernames [Array<String>] Twitter usernames.
    # @return [Array<Hashie::Mash>] Topic Objects
    # @example Return topics for damiancaruso
    # Klout::Client.topics("damiancaruso")
    def topics(usernames)
      get("/1/users/topics.json", :users => [usernames].flatten).users
    end

    # Retrieve User topics for the given username.
    #
    # @see http://developer.klout.com/docs/read/api/SOI_Methods
    # @param usernames [Array<String>] Twitter usernames.
    # @return [Array<Hashie::Mash>] User Score Pair
    # @example Return users influenced by damiancaruso
    # Klout::Client.influenced_by("damiancaruso")
    def influenced_by(usernames)
      get("/1/soi/influenced_by.json", :users => [usernames].flatten).users
    end

    # Retrieve User topics for the given username.
    #
    # @see http://developer.klout.com/docs/read/api/SOI_Methods
    # @param usernames [Array<String>] Twitter usernames.
    # @return [Array<Hashie::Mash>] User Score Pair
    # @example Return users influencers of damiancaruso
    # Klout::Client.influencer_of("damiancaruso")
    def influencer_of(usernames)
      get("/1/soi/influencer_of.json", :users => [usernames].flatten).users
    end

    private
      def get(path, params = {})
        request = HTTPI::Request.new(build_url(path, params))
        request.proxy = proxy unless proxy.nil?
        parse_response(HTTPI.get(request))
      end

      def parse_response(response)
        case response.code.to_i
        when 403
          raise Klout::Error::Forbidden.new
        when 500
          raise Klout::Error::InternalServerError.new
        when 503
          raise Klout::Error::ServiceUnavailable.new
        end
        body = ::MultiJson.decode(response.body)
        raise Klout::Error.new(body['body']['error']) if body.has_key?('body') && body['body'].has_key?('error')
        Hashie::Mash.new(body)
      end

      def build_url(path, params = {})
        "#{self.class.endpoint}#{path}?#{Rack::Utils.build_query(params.merge(:key => api_key.to_s))}"
      end
  end

  HTTPI.log = false
end
