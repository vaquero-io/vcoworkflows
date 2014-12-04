require_relative 'constants'
require 'rest_client'

module VcoWorkflows

  class VcoSession

    def initialize(uri, user: nil, password: nil, verify_ssl: false)
      api_url = "#{uri}/vco/api"
      @rest_resource = RestClient::Resource.new(api_url, :user => user, :password => password, :verify_ssl => verify_ssl)
    end

    def get(endpoint)
      response = @rest_resource[endpoint].get :accept => :json
      return response.body
    end

    def post(endpoint, body)
      response = @rest_resource[endpoint].post body, :content_type => :json
      return response.body
    end

  end

end
