require_relative 'constants'
require_relative 'workflowservice'
require_relative 'workflowtoken'
require_relative 'workflowparameter'
require 'json'

module VcoWorkflows

  class Workflow

    attr_reader :id
    attr_reader :name
    attr_reader :version
    attr_reader :description
    attr_reader :input_parameters
    attr_reader :output_parameters
    attr_accessor :workflow_service
    attr_reader :source_json

    # Public
    # @param [String] workflow_json
    # @param [VcoWorkflows::WorkflowService] workflow_service
    # @return [VcoWorkflows::Workflow]
    def initialize(workflow_json, workflow_service)

      workflow_data = JSON.parse(workflow_json)

      @workflow_service = workflow_service

      # Set up the attributes if they exist in the data json, otherwise nil them
      @id          = workflow_data.key?('id')          ? workflow_data['id']          : nil
      @name        = workflow_data.key?('name')        ? workflow_data['name']        : nil
      @version     = workflow_data.key?('version')     ? workflow_data['version']     : nil
      @description = workflow_data.key?('description') ? workflow_data['description'] : nil

      # Process the input parameters
      @input_parameters = {}
      if workflow_data.key?('input-parameters')
        workflow_data['input-parameters'].each do |params|
          wfparam = VcoWorkflows::WorkflowParameter.new(type: params['type'], name: params['name'])
          @input_parameters[params['name']] = wfparam
        end
      end

      # Process the output parameters
      @output_parameters = {}
      if workflow_data.key?('output-parameters')
        workflow_data['output-parameters'].each do |params|
          wfparam = VcoWorkflows::WorkflowParameter.new(type: params['type'], name: params['name'])
          @output_parameters[params['name']] = wfparam
        end
      end

      # Get the presentation data and set required flags on our parameters
      @presentation = workflow_service.get_presentation(@id, self)

    end

    # Public
    # @return [String]
    def get_required_parameters
      required = []
      @input_parameters.each_value {|v| required << v.name if v.required}
      return required
    end

    # Public
    def verify_parameters
      self.get_required_parameters.each do |param_name|
        param = @input_parameters['param_name']
        if param.required && (param.value.nil? || param.value.size == 0)
          fail(IOError, ERR[:param_verify_failed] << "#{param_name} required but not present.")
        end
      end
    end

    # Public
    # @param [VcoWorkflows::WorkflowService] workflow_service
    # @return [VcoWorkflows::WorkflowToken]
    def execute(workflow_service)
      # If we're not given an explicit workflow service for this execution
      # request, use the one defined when we were created.
      workflow_service = @workflow_service if workflow_service.nil?

      # If we still have a nil workflow_service, go home.
      fail(IOError, ERR[:no_workflow_service_defined]) if workflow_service.nil?

      workflow_service.exececute_workflow(id: @id, parameter_json: param_struct.to_json)

    end

    # Private methods
    private

    def get_input_parameter_json
      tmp_params = []
      @input_parameters.each {|p| tmp_params << p.as_struct}
      param_struct = {:parameters => tmp_params}
      param_struct.to_json
    end

  end

end
