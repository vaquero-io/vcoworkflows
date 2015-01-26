require_relative 'constants'
require 'rest_client'

# rubocop:disable HashSyntax

# VcoWorkflows
module VcoWorkflows
  # VcoSession
  class VcoSession

    attr_reader :rest_resource

    # Initialize the session
    #
    # @param [String] uri URI for the vCenter Orchestrator API endpoint
    # @param [String] user User name for vCO
    # @param [String] password Password for vCO
    # @param [Boolean] verify_ssl Whether or not to verify SSL certificates
    def initialize(uri, user: nil, password: nil, verify_ssl: true)
      api_url = "#{uri.gsub(/\/$/, '')}/vco/api"
      RestClient.proxy = ENV['http_proxy'] # Set a proxy if present
      @rest_resource = RestClient::Resource.new(api_url,
                                                :user => user,
                                                :password => password,
                                                :verify_ssl => verify_ssl)
    end

    # Perform a REST GET operation against the specified endpoint
    #
    # @param [String] endpoint REST endpoint to use
    # @param [Hash] headers Optional headers to use in request
    # @return [String] JSON response body
    def get(endpoint, headers = {})
      headers = { :accept => :json }.merge(headers)
      @rest_resource[endpoint].get headers
    end

    # Perform a REST POST operation against the specified endpoint with the
    # given data body
    #
    # @param [String] endpoint REST endpoint to use
    # @param [String] body JSON data body to post
    # @param [Hash] headers Optional headers to use in request
    # @return [String] JSON response body
    def post(endpoint, body, headers = {})
      headers = { :accept => :json, :content_type => :json }.merge(headers)
      @rest_resource[endpoint].post body, headers
    end
  end
end

# rubocop:enable HashSyntax
