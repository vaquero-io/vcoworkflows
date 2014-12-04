require_relative 'constants'
require 'httparty'
require 'erb'

# Bring HTTP to the party
include HTTParty

include ERB::Util

module VcoWorkflows

  class VcoSession

    # Add headers to our requests
    headers 'Content-Type' => 'application/json'
    headers 'Accept' => 'application/json'

    def initialize(uri: nil, user: nil, passwd: nil, sslverify: false)
      # Set the httparty base_uri
      @base_uri = "#{uri}/#{API_URL_BASE}"
      # Configure the authentication
      @auth = {:username => user, :password => passwd}
      # Set SSL Verification
      default_options.update(verify: sslverify)
    end

    def get(endpoint: nil)
      options[:basic_auth] = @auth
      response_json = self.class.get(@base_uri << url_encode(endpoint), options)
      return response_json
    end

    def post(endpoint: nil, body: nil)
      options[:basic_auth] = @auth
      options[:body] = body
      response_json = self.class.post(@base_uri << url_encode(endpoint), options)
      return response_json
    end

  end

end
