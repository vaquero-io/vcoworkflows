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
      class_option :verify_ssl, type: :boolean, default: true, desc: DESC_CLI_VERIFY_SSL
      class_option :dry_run, type: :boolean, desc: DESC_CLI_DRY_RUN
      class_option :verbose, type: :boolean, default: true, desc: DESC_CLI_VERBOSE

      class_option :parameters, type: :string, required: true, desc: DESC_CLI_EXECUTE_PARAMETERS

      def self.source_root
        File.dirname(__FILE__)
      end

      def execute

        # Parse out the parameters
        parameters = {}
        options[:parameters].split(/,/).each { |p| k, v = p.split(/=/); parameters[k] = v }
        if parameters.key?('runlist')
          parameters['runlist'] = parameters['runlist'].split(/:/)
        end

        puts "Executing against vCO REST endpoint: #{options[:server]}"
        puts "Requested execution of workflow: '#{workflow}'"
        puts "Will call workflow by GUID (#{options[:id]})" if options[:id]
        if options[:verbose] || options[:dry_run]
          puts "Parameters:"
          parameters.each {|k,v| v = v.join(',') if v.is_a?(Array); puts " - #{k}: #{v}"}
          puts ""
        end

        return if options[:dry_run]

        # Create the session
        session = VcoWorkflows::VcoSession.new(options[:server],
                                               user: options[:username],
                                               password: options[:password],
                                               verify_ssl: options[:verify_ssl])

        # Create the Workflow Service
        wfs = VcoWorkflows::WorkflowService.new(session)

        # Get the workflow
        puts "Retrieving workflow '#{workflow}' ..."
        wf = nil
        if options.key?(:id)
          wf = wfs.get_workflow_for_id(options[:id])
        else
          wf = wfs.get_workflow_for_name(workflow)
        end

        # Set the input parameters
        puts "Setting workflow input parameters..." if options[:verbose]
        parameters.each {|k,v| puts "setting #{k} to #{v}" if options[:verbose]; wf.set_parameter(k,v)}

        # Verify parameters
        puts "Verifying required parameters..." if options[:verbose]
        wf.verify_parameters

        # Execute the workflow
        puts "Executing workflow..."
        # puts JSON.pretty_generate(JSON.parse(wf.get_input_parameter_json))
        wftoken = wf.execute
        puts "Execution of #{wf.name} started at #{Time.at(wftoken.start_date/1000)}"
        puts "Execution #{wftoken.id} state: #{wftoken.state}"
        while wftoken.state.eql?('running') do
          sleep 5
          wftoken = wfs.get_execution(wf.id, wftoken.id)
          puts "Execution #{wftoken.id} state: #{wftoken.state}"
        end

        puts JSON.parse(wfs.get_log(wf.id,wftoken.id))

      end

    end

  end

end
