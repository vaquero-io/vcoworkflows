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

      workflow_data = JSON.parse(workflow_json)

      @id = workflow_data['id']
      @name = workflow_data['name']
      @version = workflow_data['version']
      @description = workflow_data['description']

      # Process the input parameters
      workflow_data['input-parameters'].each do |paramhash|
        @inParameters[paramhash['name']] = paramhash['type']
      end

      # Process the output parameters
      workflow_data['output-parameters'].each do |paramhash|
        @outParameters[paramhash['name']] = paramhash['type']
      end

    end

    def execute(workflow_service: nil)

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
