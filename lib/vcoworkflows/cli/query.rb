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
      class_option :verify_ssl, type: :boolean, default: true, desc: DESC_CLI_VERIFY_SSL
      class_option :dry_run, type: :boolean, default: false, desc: DESC_CLI_DRY_RUN

      class_option :executions, type: :boolean, aliases: '-e', default: false
      class_option :executions_limit, type: :numeric, aliases: '-l', default: 0
      class_option :execution_id, type: :string, aliases: '-I'
      class_option :state, type: :boolean, aliases: '-r'
      class_option :logs, type: :boolean, aliases: ['-L','--log']
      class_option :input_parameters, type: :boolean, default: false
      class_option :show_json, type: :boolean, default: false

      def self.source_root
        File.dirname(__FILE__)
      end

      def query

        # puts "#{JSON.pretty_generate({'options' => options})}"

        if options[:dry_run]
          puts "\nQuerying against vCO REST endpoint:\n  #{options[:server]}"
          puts "Will search for workflow: '#{workflow}'"
          puts "Will query workflow by GUID (#{options[:id]})" if options[:id]
          return
        end

        # Create the session
        session = VcoWorkflows::VcoSession.new(options[:server],
                                               user: options[:username],
                                               password: options[:password],
                                               verify_ssl: options[:verify_ssl])

        # Create the Workflow Service
        wfs = VcoWorkflows::WorkflowService.new(session)

        puts "\nRetrieving workflow '#{workflow}' ..."

        wf = nil
        if options[:id]
          wf = wfs.get_workflow_for_id(options[:id])
        else
          wf = wfs.get_workflow_for_name(workflow)
        end

        puts ""
        if options[:execution_id]
          puts "Fetching data for execution #{options[:execution_id]}..."
          execution = wfs.get_execution(wf.id, options[:execution_id])
          if options[:state]
            puts "Execution started at #{Time.at(execution.start_date/1000)}"
            puts "Execution #{execution.state} at #{Time.at(execution.end_date/1000)}"
          else
            puts ""
            if options[:show_json]
              puts execution.to_json
            else
              puts execution
            end
            if options[:input_parameters]

            end
          end

          if options[:logs]
            puts ""
            wftoken = wfs.get_log(wf.id, options[:execution_id])
            if options[:show_json]
              puts wftoken.to_json
            else
              puts wftoken
            end
          end
        else
          puts wf
        end
        
        if options[:executions]
          puts "\nExecutions: "
          executions = {}
          wfs.get_execution_list(wf.id).each_value do |attrs|
            executions[attrs['startDate']] = attrs
          end
          keys = executions.keys.sort
          if options[:executions_limit] > 0
            keys = keys.slice(keys.size - options[:executions_limit], keys.size)
          end
          keys.each do |timestamp|
            puts "#{timestamp} [#{executions[timestamp]['id']}] #{executions[timestamp]['state']}"
          end
        end

      end

    end

  end

end
