require_relative 'constants'
require_relative 'vcosession'
require_relative 'workflow'
require_relative 'workflowexecutionlog'
require 'json'
require 'erb'

include ERB::Util

module VcoWorkflows

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
    # @param [VcoWorkflows::Workflow] workflow - workflow GUID who's presentation we want
    # @return [VcoWorkflows::WorkflowPresentation]
    def get_presentation(workflow)
      VcoWorkflows::WorkflowPresentation.new(@session.get("/workflows/#{workflow.id}/presentation/").body, workflow)
    end

    # Public
    # Get one workflow with a specified name.
    # @param [String] name - Name of the workflow
    # @return [VcoWorkflows::Workflow] - the requested workflow
    def get_workflow_for_name(name)
      response = JSON.parse(@session.get("/workflows?conditions=name=#{url_encode(name)}").body)

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

    def get_execution(workflow_id, execution_id)
      response = @session.get("/workflows/#{workflow_id}/executions/#{execution_id}")
      VcoWorkflows::WorkflowToken.new(response.body, workflow_id)
    end

    def get_log(workflow_id, execution_id)
      response = @session.get("/workflows/#{workflow_id}/executions/#{execution_id}/logs/")
      VcoWorkflows::WorkflowExecutionLog.new(response.body)
    end

    # Public
    # Submit the given workflow for execution
    # @param [String] id - Workflow GUID for the workflow we want to execute
    # @param [String] parameter_json - Required workflow input parameters as JSON
    def execute_workflow(id, parameter_json)
      # response = JSON.parse(@session.post("/workflows/#{id}/executions/", parameter_json))
      response = @session.post("/workflows/#{id}/executions/", parameter_json)
      execution_id = response.headers[:location].gsub(/^.*\/executions\//,'')
      get_execution(id, execution_id)
    end

  end

end
