require 'vcoworkflows/constants'

# VcoWorkflows
module VcoWorkflows
  # Cli
  module Cli
    # Auth
    class Auth
      attr_reader :username
      attr_reader :password

      # Initialize the Auth object
      # @param [String] username
      # @param [String] password
      def initialize(username: nil, password: nil)
        # Set username and password from parameters, if provided, or
        # environment variables $VCO_USER and $VCO_PASSWD, if not.
        @username = username.nil? ? ENV['VCO_USER'] : username
        @password = password.nil? ? ENV['VCO_PASSWD'] : password

        # Fail if we don't have both a username and a password.
        fail(IOError, ERR[:username_unset]) if @username.nil?
        fail(IOError, ERR[:password_unset]) if @password.nil?
      end
    end
  end
end
