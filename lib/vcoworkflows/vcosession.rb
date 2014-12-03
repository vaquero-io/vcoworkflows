require_relative 'constants'
require 'httparty'

module VcoWorkflows

  class VcoSession

    # Bring HTTP to the party
    include 'httparty'

    # Add headers to our requests
    headers 'Content-Type' => 'application/json'
    headers 'Accept' => 'application/json'

    def initialize(uri: nil, user: nil, passwd: nil, sslverify: false)
      # Set the httparty base_uri
      base_uri "#{uri}/#{API_URL_BASE}"
      # Configure the authentication
      @auth = {:username => user, :password => passwd}
      # Set SSL Verification
      default_options.update(verify: sslverify)
    end

    def get(endpoint: nil)
      options[:basic_auth] = @auth
      response_json = self.class.get(endpoint, options)
      return response_json
    end

    def post(endpoint: nil, body: nil)
      options[:basic_auth] = @auth
      options[:body] = body
      response_json = self.class.post(endpoint, options)
      return response_json
    end

  end

end
