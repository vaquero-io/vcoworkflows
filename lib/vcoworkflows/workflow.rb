require_relative 'constants'
require_relative 'workflowservice'
require_relative 'workflowpresentation'
require_relative 'workflowtoken'
require_relative 'workflowparameter'
require 'json'

# VcoWorkflows
module VcoWorkflows
  # rubocop:disable ClassLength

  # Class to represent a Workflow as presented by vCenter Orchestrator.
  class Workflow
    attr_reader :id
    attr_reader :name
    attr_reader :version
    attr_reader :description
    attr_reader :input_parameters
    attr_reader :output_parameters
    attr_accessor :service
    attr_reader :execution_id

    attr_reader :source_json

    # rubocop:disable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    # Create a Workflow object given vCenter Orchestrator's JSON description
    #
    # When passed `url`, `username` and `password` the necessary session and
    # service objects will be created behind the scenes. Alternatively you can
    # pass in a VcoSession object or a WorkflowService object if you have
    # constructed them yourself.
    # @param [String] name Name of the requested workflow
    # @param [Hash] options Hash of options, see README.md for details
    # @return [VcoWorkflows::Workflow]
    def initialize(name = nil, options = {})
      @options = {
        id: nil,
        url: nil,
        username: nil,
        password: nil,
        verify_ssl: true,
        service: nil
      }.merge(options)

      @service = nil
      @execution_id = nil

      # -------------------------------------------------------------
      # Figure out how to get a workflow service. If I can't, I die.
      # (DUN dun dun...)

      if options[:service]
        @service = options[:service]
      elsif @options[:url] && @options[:username] && @options[:password]
        session = VcoWorkflows::VcoSession.new(@options[:url],
                                               user: @options[:username],
                                               password: @options[:password],
                                               verify_ssl: @options[:verify_ssl])
        @service = VcoWorkflows::WorkflowService.new(session)
      end

      fail(IOError, 'Unable to create/use a WorkflowService!') if @service.nil?

      # -------------------------------------------------------------
      # Retrieve the workflow and parse it into a data structure
      # If we're given both a name and ID, prefer the id
      if @options[:id]
        workflow_json = @service.get_workflow_for_id(@options[:id])
      else
        workflow_json = @service.get_workflow_for_name(name)
      end
      workflow_data = JSON.parse(workflow_json)

      # Set up the attributes if they exist in the data json, otherwise nil them
      @id          = workflow_data.key?('id')          ? workflow_data['id']          : nil
      @name        = workflow_data.key?('name')        ? workflow_data['name']        : nil
      @version     = workflow_data.key?('version')     ? workflow_data['version']     : nil
      @description = workflow_data.key?('description') ? workflow_data['description'] : nil

      # Process the input parameters
      if workflow_data.key?('input-parameters')
        @input_parameters = Workflow.parse_parameters(workflow_data['input-parameters'])
      else
        @input_parameters = {}
      end

      # Identify required input_parameters
      wfpres = VcoWorkflows::WorkflowPresentation.new(@service, @id)
      wfpres.required.each do |req_param|
        @input_parameters[req_param].required(true)
      end

      # Process the output parameters
      if workflow_data.key?('output-parameters')
        @output_parameters = Workflow.parse_parameters(workflow_data['output-parameters'])
      else
        @output_parameters = {}
      end
    end
    # rubocop:enable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    def url
      options[:url]
    end

    def username
      options[:username]
    end

    def password
      options[:password]
    end

    def verify_ssl?
      options[:verify_ssl]
    end

    # rubocop:disable MethodLength, LineLength

    # Parse json parameters and return a nice hash
    # @param [Object] parameter_data JSON document of parameters as defined
    # by vCO
    # @return [Hash]
    def self.parse_parameters(parameter_data)
      wfparams = {}
      parameter_data.each do |parameter|
        wfparam = VcoWorkflows::WorkflowParameter.new(parameter['name'],
                                                      parameter['type'])
        if parameter['value']
          if wfparam.type.eql?('Array')
            value = []
            begin
              parameter['value'][wfparam.type.downcase]['elements'].each do |element|
                value << element[element.keys.first]['value']
              end
            rescue StandardError => error
              parse_failure(error)
            end
          else
            begin
              value = parameter['value'][parameter['value'].keys.first]['value']
            rescue StandardError => error
              parse_failure(error)
            end
          end
          value = nil if value.eql?('null')
          wfparam.set(value)
        end
        wfparams[parameter['name']] = wfparam
      end
      wfparams
    end
    # rubocop:enable MethodLength, LineLength

    # rubocop:disable LineLength

    # Process exceptions raised in parse_parameters by bravely ignoring them
    # and forging ahead blindly!
    # @param [Exception] error
    def self.parse_failure(error)
      $stderr.puts "\nWhoops!"
      $stderr.puts "Ran into a problem parsing parameter #{wfparam.name} (#{wfparam.type})!"
      $stderr.puts "Source data: #{JSON.pretty_generate(parameter)}\n"
      $stderr.puts error.message
      $stderr.puts "\nBravely forging on and ignoring parameter #{wfparam.name}!"
    end
    # rubocop:enable LineLength

    # rubocop:disable LineLength

    # Get an array of the names of all the required input parameters
    # @return [Hash] Hash of WorkflowParameter input parameters which are required for this workflow
    def required_parameters
      required = {}
      @input_parameters.each_value { |v| required[v.name] = v if v.required? }
    end
    # rubocop:enable LineLength

    # Get the value of a specific input parameter
    # @param [String] parameter_name - Name of the parameter whose value to get
    # @return [VcoWorkflows::WorkflowParameter]
    def parameter(parameter_name)
      @input_parameters[parameter_name]
    end

    # rubocop:disable LineLength

    # Set a parameter to a value
    # @param [String] parameter - name of the parameter to set
    # @param [Object] value - value to set
    def set_parameter(parameter_name, value)
      if @input_parameters.key?(parameter_name)
        @input_parameters[parameter_name].set value
      else
        $stderr.puts "\nAttempted to set a value for a non-existent WorkflowParameter!"
        $stderr.puts "It appears that there is no parameter \"#{parameter}\"."
        $stderr.puts "Valid parameter names are: #{@input_parameters.keys.join(', ')}"
        $stderr.puts ''
        fail(IOError, ERR[:no_such_parameter])
      end
    end
    # rubocop:enable LineLength

    # rubocop:disable LineLength

    # Verify that all mandatory input parameters have values
    private def verify_parameters
      required_parameters.each do |name, wfparam|
        if wfparam.required? && (wfparam.value.nil? || wfparam.value.size == 0)
          fail(IOError, ERR[:param_verify_failed] << "#{name} required but not present.")
        end
      end
    end
    # rubocop:enable LineLength

    # rubocop:disable LineLength

    # Execute this workflow
    # @param [VcoWorkflows::WorkflowService] workflow_service
    # @return [String] Workflow Execution ID
    def execute(workflow_service = nil)
      # If we're not given an explicit workflow service for this execution
      # request, use the one defined when we were created.
      workflow_service = @service if workflow_service.nil?
      # If we still have a nil workflow_service, go home.
      fail(IOError, ERR[:no_workflow_service_defined]) if workflow_service.nil?
      # Make sure we didn't forget any required parameters
      verify_parameters
      # Let's get this thing running!
      @execution_id = workflow_service.execute_workflow(@id, input_parameter_json)
    end
    # rubocop:enable LineLength

    # Return a WorkflowToken
    def token(execution_id = nil)
      execution_id = @execution_id if execution_id.nil?
      VcoWorkflows::WorkflowToken.new(@service, @id, execution_id)
    end

    def log(execution_id = nil)
      execution_id = @execution_id if execution_id.nil?
      log_json = @service.get_log(@id, execution_id)
      VcoWorkflows::WorkflowExecutionLog.new(log_json)
    end

    # rubocop:disable MethodLength

    # @return [String]
    def to_s
      string =  "Workflow:    #{@name}\n"
      string << "ID:          #{@id}\n"
      string << "Description: #{@description}\n"
      string << "Version:     #{@version}\n"

      string << "\nInput Parameters:\n"
      if @input_parameters.size > 0
        @input_parameters.each_value { |wf_param| string << " #{wf_param}" }
      end

      string << "\nOutput Parameters:" << "\n"
      if @output_parameters.size > 0
        @output_parameters.each_value { |wf_param| string << " #{wf_param}" }
      end

      # Assert
      string
    end
    # rubocop:enable MethodLength

    private

    # Convert the input parameters to a JSON document
    # @return [String]
    def input_parameter_json
      tmp_params = []
      @input_parameters.each_value { |v| tmp_params << v.as_struct if v.set? }
      param_struct = { parameters: tmp_params }
      param_struct.to_json
    end
  end
  # rubocop:enable ClassLength
end
