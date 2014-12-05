require_relative 'constants'
require_relative 'vcosession'
require_relative 'workflow'
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
    def get_presentation(id, workflow)
      VcoWorkflows::WorkflowPresentation.new(@session.get("/workflows/#{id}/presentation/"), workflow)
    # @param [VcoWorkflows::Workflow] workflow - workflow GUID who's presentation we want
    # @return [VcoWorkflows::WorkflowPresentation]
    end

    # Public
    # Get one workflow with a specified name.
    # @param [String] name - Name of the workflow
    # @return [VcoWorkflows::Workflow] - the requested workflow
    def get_workflow_for_name(name)
      response = JSON.parse(@session.get("/workflows?conditions=name=#{url_encode(name)}"))

      # barf if we got anything other than a single workflow
      fail(IOError, ERR[:too_many_workflows]) if response['total'] > 1
      fail(IOError, ERR[:no_workflow_found]) if response['total'] == 0

      # yank out the workflow id and name from the result attributes
      workflow_id = nil
      workflow_name = nil
      response['link'][0]['attributes'].each do |a|
        workflow_id = a['value'] if a['name'].eql?('id')
        workflow_name = a['value'] if a['name'].eql?('name')
      end

      # Barf if we got this far and the workflow we found has a different
      # name than what we went looking for.
      fail(IOError, ERR[:wrong_workflow_wtf]) unless workflow_name.eql?(name)

      # Get the workflow by GUID
      get_workflow_for_id(workflow_id)
    end

    # Public
    # Submit the given workflow for execution
    # @param [String] id - Workflow GUID for the workflow we want to execute
    # @param [String] parameter_json - Required workflow input parameters as JSON
    def execute_workflow(id, parameter_json)
      response = JSON.parse(@session.post("/workflows/#{id}/executions/", parameter_json))
    end

  end

end
