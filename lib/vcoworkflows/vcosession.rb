require_relative 'constants'
require 'rest_client'

module VcoWorkflows

  class VcoSession

    def initialize(uri, user: nil, password: nil, verify_ssl: false)
      api_url = "#{uri}/vco/api"
      @rest_resource = RestClient::Resource.new(api_url, :user => user, :password => password, :verify_ssl => verify_ssl)
    end

    def get(endpoint, headers: {})
      default_headers = {:accept => :json}
      final_headers = default_headers.merge(headers)
      response = @rest_resource[endpoint].get final_headers
      return response.body
    end

    def post(endpoint, body, headers: {})
      default_headers = {:content_type => :json}
      final_headers = default_headers.merge(headers)
      response = @rest_resource[endpoint].post body, final_headers
      return response.body
    end

  end

end
