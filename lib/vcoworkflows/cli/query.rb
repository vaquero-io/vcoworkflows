require 'vcoworkflows'
require 'thor/group'

module VcoWorkflows

  module Cli

    class Query < Thor::Group

      include Thor::Actions

      argument :workflow, type: :string, desc: DESC_CLI_WORKFLOW
      class_option :server, type: :string, aliases: '-s', required: true, desc: DESC_CLI_SERVER
      class_option :username, type: :string, aliases: '-u', desc: DESC_CLI_USERNAME
      class_option :password, type: :string, aliases: '-p', desc: DESC_CLI_PASSWORD
      class_option :id, type: :string, aliases: '-i', desc: DESC_CLI_WORKFLOW_ID
      class_option 'verify-ssl', type: :boolean, default: true, desc: DESC_CLI_VERIFY_SSL
      class_option 'dry-run', type: :boolean, desc: DESC_CLI_DRY_RUN

      def self.source_root
        File.dirname(__FILE__)
      end

      def query

        puts "\nQuerying against vCO REST endpoint:\n  #{options[:server]}"
        puts "Will search for workflow: '#{workflow}'"
        puts "Will query workflow by GUID (#{options[:id]})" if options[:id]

        return if options[:dry_run]
        
        # Create the session
        session = VcoWorkflows::VcoSession.new(options[:server],
                                               user: options[:username],
                                               password: options[:password],
                                               verify_ssl: options[:verify_ssl])

        # Create the Workflow Service
        wfs = VcoWorkflows::WorkflowService.new(session)

        puts "\nRetrieving workflow '#{workflow}' ..."

        wf = nil
        if options.key?(:id)
          wf = wfs.get_workflow_for_id(options[:id])
        else
          wf = wfs.get_workflow_for_name(workflow)
        end

        puts ""
        puts wf.to_s

      end

    end

  end

end
