require 'vcoworkflows/constants'

# VcoWorkflows
module VcoWorkflows
  # Cli
  module Cli
    # Auth is a very small helper class to allow pulling authentication
    # credentials from the environment when using one of the executable
    # commands.
    #
    # If credentials aren't passed in as options to the command, we'll
    # also check the environment for $VCO_USER and $VCO_PASSWD and use
    # those. Otherwise, command line options will override environment
    # values.
    class Auth
      attr_reader :username
      attr_reader :password

      # Initialize the Auth object. If the paramaters are nil, look
      # for values in the environment instead.
      # @param [String] username vCenter Orchestrator user name
      # @param [String] password vCenter Orchestrator password
      # @return [VcoWorkflows::Cli::Auth]
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
