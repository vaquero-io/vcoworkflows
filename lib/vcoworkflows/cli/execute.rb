require 'vcoworkflows/constants'
require 'thor/group'

module VcoWorkflows

  module Cli

    class Execute < Thor::Group

      include Thor::Actions

      argument :workflow, type: :string, desc: DESC_CLI_WORKFLOW
      class_option :server, type: :string, aliases: '-s', required: true, desc: DESC_CLI_SERVER
      class_option :username, type: :string, aliases: '-u', desc: DESC_CLI_USERNAME
      class_option :password, type: :string, aliases: '-p', desc: DESC_CLI_PASSWORD
      class_option :id, type: :string, aliases: '-i', desc: DESC_CLI_WORKFLOW_ID
      class_option 'verify-ssl', type: :boolean, default: true, desc: DESC_CLI_VERIFY_SSL
      class_option 'dry-run', type: :boolean, desc: DESC_CLI_DRY_RUN

      class_option :parameters, type: :string, requires: true, desc: DESC_CLI_EXECUTE_PARAMETERS

      def self.source_root
        File.dirname(__FILE__)
      end

      def execute
        puts "Executing against vCO REST endpoint: #{options[:server]}"
        puts "Requested execution of workflow: '#{workflow}'"
        puts "Will call workflow by GUID (#{options[:id]})" if options[:id]
        options[:parameters].split(/,/).each {|p| puts "Parameter: #{p.gsub(/=.*$/,'')} = #{p.gsub(/^.*=/,'')}"}
      end

    end

  end

end
