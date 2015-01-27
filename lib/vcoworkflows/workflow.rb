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
    attr_accessor :workflow_service

    attr_reader :source_json

    # rubocop:disable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    # Create a Workflow object given vCenter Orchestrator's JSON description
    #
    # When passed `url`, `username` and `password` the necessary session and
    # service objects will be created behind the scenes. Alternatively you can
    # pass in a VcoSession object or a WorkflowService object if you have
    # constructed them yourself.
    # @param [String] url full URL to vCO API Endpoint (i.e. https://vco.example.com:8281/vco/api)
    # @param [String] username vCO user name
    # @param [String] password vCO password
    # @param [VcoWorkflows::VcoSession] session VcoSession object, if not specifying url, username and password
    # @param [VcoWorkflows::WorkflowService] service WorkflowService, if not specifying url, username and password OR session
    # @param [String] name Workflow name
    # @param [String] id Workflow GUID
    # @param [Boolean] verify_ssl control SSL certificate verification for connections to vCO
    # @return [VcoWorkflows::Workflow]
    def initialize(name = nil,
                   url: nil,
                   username: nil,
                   password: nil,
                   session: nil,
                   service: nil,
                   id: nil,
                   verify_ssl: true)

      @workflow_service = nil
      @session = nil

      # -------------------------------------------------------------
      # Figure out how to get a workflow service. If I can't, I die.
      # (DUN dun dun...)

      # If I'm handed one, I'll just use that
      if service
        @workflow_service = service
      else
        # If I'm just handed a session, I'll use that to fetch a service
        if session
          @session = session
        # Otherwise, if I'm handed a url, username and password, I'll do all
        # the work myself.
        elsif url && username && password
          @session = VcoWorkflows::VcoSession.new(url,
                                                  user: username,
                                                  password: password,
                                                  verify_ssl: verify_ssl)
        end
        @workflow_service = VcoWorkflows::WorkflowService.new(@session)
      end

      fail(IOError, 'Unable to create/use a WorkflowService!') if @workflow_service == nil

      # -------------------------------------------------------------
      # Retrieve the workflow and parse it into a data structure
      # If we're given both a name and ID, prefer the id
      name = nil if name && id
      workflow_json = @workflow_service.get_workflow_for_id(id) if id && ! name
      workflow_json = @workflow_service.get_workflow_for_name(name) if name && ! id
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

      # Process the output parameters
      if workflow_data.key?('output-parameters')
        @output_parameters = Workflow.parse_parameters(workflow_data['output-parameters'])
      else
        @output_parameters = {}
      end
    end
    # rubocop:enable CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength

    # rubocop:disable MethodLength, LineLength

    # Parse json parameters and return a nice hash
    # @param [Object] parameter_data JSON document of parameters as defined
    # by vCO
    # @return [Hash]
    def self.parse_parameters(parameter_data)
      wfparams = {}
      parameter_data.each do |parameter|
        wfparam = VcoWorkflows::WorkflowParameter.new(type: parameter['type'],
                                                      name: parameter['name'])
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

    # Get an array of the names of all the required input parameters
    # @return [String[]]
    def required_parameter_names
      required = []
      @input_parameters.each_value { |v| required << v.name if v.required? }
    end

    # Get an array of the full set of input parameters
    # @return [String[]]
    def parameter_names
      @input_parameters.keys
    end

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
    def set_parameter(parameter, value)
      if @input_parameters.key?(parameter)
        @input_parameters[parameter].set value
      else
        $stderr.puts "\nAttempted to set a value for a non-existent WorkflowParameter!"
        $stderr.puts "It appears that there is no parameter \"#{parameter}\"."
        $stderr.puts "Valid parameter names are: #{parameter_names.join(', ')}"
        $stderr.puts ''
        fail(IOError, ERR[:no_such_parameter])
      end
    end
    # rubocop:enable LineLength

    # rubocop:disable LineLength

    # Verify that all mandatory input parameters have values
    def verify_parameters
      required_parameter_names.each do |name|
        param = @input_parameters[name]
        if param.required? && (param.value.nil? || param.value.size == 0)
          fail(IOError, ERR[:param_verify_failed] << "#{name} required but not present.")
        end
      end
    end
    # rubocop:enable LineLength

    # Execute this workflow
    # @param [VcoWorkflows::WorkflowService] workflow_service
    # @return [VcoWorkflows::WorkflowToken]
    def execute(workflow_service = nil)
      # If we're not given an explicit workflow service for this execution
      # request, use the one defined when we were created.
      workflow_service = @workflow_service if workflow_service.nil?
      # If we still have a nil workflow_service, go home.
      fail(IOError, ERR[:no_workflow_service_defined]) if workflow_service.nil?
      # Let's get this thing running!
      workflow_service.execute_workflow(@id, input_parameter_json)
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

    # rubocop:disable HashSyntax

    # Convert the input parameters to a JSON document
    # @return [String]
    def input_parameter_json
      tmp_params = []
      @input_parameters.each_value { |v| tmp_params << v.as_struct if v.set? }
      param_struct = { :parameters => tmp_params }
      param_struct.to_json
    end
    # rubocop:enable HashSyntax
  end
  # rubocop:enable ClassLength

end
