require_relative 'constants'
require_relative 'vcosession'
require_relative 'workflow'
require_relative 'workflowexecutionlog'
require 'json'
require 'erb'

include ERB::Util

module VcoWorkflows
  # WorkflowService
  class WorkflowService
    # Public
    # Initialize the object
    def initialize(session)
      @session = session
    end

    # Public
    # Get a workflow by GUID
    # @param [String] id - Workflow GUID
    # @return [VcoWorkflows::Workflow] - the requested workflow
    def get_workflow_for_id(id)
      VcoWorkflows::Workflow.new(@session.get("/workflows/#{id}"), self)
    end

    # Public
    # Get the presentation for the given workflow GUID
    # @param [VcoWorkflows::Workflow] workflow - workflow GUID
    # @return [VcoWorkflows::WorkflowPresentation]
    def get_presentation(workflow)
      VcoWorkflows::WorkflowPresentation.new(
          @session.get("/workflows/#{workflow.id}/presentation/").body,
          workflow
      )
    end

    # Public
    # Get one workflow with a specified name.
    # @param [String] name - Name of the workflow
    # @return [VcoWorkflows::Workflow] - the requested workflow
    def get_workflow_for_name(name)
      path = "/workflows?conditions=name=#{url_encode(name)}"
      response = JSON.parse(@session.get(path).body)

      # barf if we got anything other than a single workflow
      fail(IOError, ERR[:too_many_workflows]) if response['total'] > 1
      fail(IOError, ERR[:no_workflow_found]) if response['total'] == 0

      # yank out the workflow id and name from the result attributes
      workflow_id = nil
      response['link'][0]['attributes'].each do |a|
        workflow_id = a['value'] if a['name'].eql?('id')
      end

      # Get the workflow by GUID
      get_workflow_for_id(workflow_id)
    end

    # Public
    # Get a WorkflowToken for the requested workflow_id and execution_id
    # @param [String] workflow_id - Workflow GUID
    # @param [String] execution_id - Execution GUID
    # @return [VcoWorkflows::WorkflowToken]
    def get_execution(workflow_id, execution_id)
      path = "/workflows/#{workflow_id}/executions/#{execution_id}"
      response = @session.get(path)
      VcoWorkflows::WorkflowToken.new(response.body, workflow_id)
    end

    # Public
    # Get a list of executions for the given workflow GUID
    # @param [String] workflow_id - Workflow GUID
    # @return [Hash]
    def get_execution_list(workflow_id)
      path = "/workflows/#{workflow_id}/executions/"
      relations = JSON.parse(@session.get(path).body)['relations']
      # The first two elements of the relations['link'] array are URLS,
      # so scrap them. Everything else is an execution.
      executions = {}
      relations['link'].each do |link|
        next unless link.key?('attributes')
        attributes = {}
        link['attributes'].each { |a| attributes[a['name']] = a['value'] }
        executions[attributes['id']] = attributes
      end
      executions
    end

    # Public
    # Get the log for a specific execution
    # @param [String] workflow_id
    # @param [String] execution_id
    # @return [VcoWorkflows::WorkflowExecutionLog]
    def get_log(workflow_id, execution_id)
      path = "/workflows/#{workflow_id}/executions/#{execution_id}/logs/"
      response = @session.get(path)
      VcoWorkflows::WorkflowExecutionLog.new(response.body)
    end

    # Public
    # Submit the given workflow for execution
    # @param [String] id - Workflow GUID for the workflow we want to execute
    # @param [String] parameter_json - JSON document of input parameters
    def execute_workflow(id, parameter_json)
      path = "/workflows/#{id}/executions/"
      response = @session.post(path, parameter_json)
      execution_id = response.headers[:location].gsub(%r{^.*/executions/}, '')
      get_execution(id, execution_id)
    end
  end
end
