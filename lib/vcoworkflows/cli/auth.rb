require 'vcoworkflows'

# VcoWorkflows
module VcoWorkflows
  # Cli
  module Cli
    # Auth
    class Auth
      attr_reader :username
      attr_reader :password

      # Public
      # Initialize the Auth object
      # @param [String] username
      # @param [String] password
      # rubocop:disable LineLength
      def initialize(username: nil, password: nil)
        # First we try to use whatever we were given.
        @username = username
        @password = password

        # If we were given nothing, See if we can get username and password
        # from the environment $VCO_USER and $VCO_PASSWD
        @username = ENV['VCO_USER'] unless ENV['VCO_USER'].nil? if @username.nil?
        @password = ENV['VCO_PASSWD'] unless ENV['VCO_PASSWD'].nil? if @password.nil?

        # If we still got nothing, die a horrible death
        fail(IOError, ERR[:username_unset]) if @username.nil?
        fail(IOError, ERR[:password_unset]) if @password.nil?
      end
      # rubocop:enable LineLength
    end
  end
end
