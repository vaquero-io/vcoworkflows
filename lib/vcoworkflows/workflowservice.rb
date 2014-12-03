require_relative 'constants'
require_relative 'vcosession'
require 'json'

module VcoWorkflows

  class WorkflowService

    # Public
    # Initialize the object
    def initialize(session: VcoSession)
      @session = session
    end

    # Public
    # Get a workflow by GUID
    def getWorkflowForId(id: nil)
      VcoWorkflows::Workflow.new(@session.get("/workflows/#{id}"))
    end

    # Public
    # Get one workflow with a specified name. If we find none or more
    # than one workflow for the given name, it is an error condition and
    # we need to fail violently.
    def getWorkflowForName(name: nil)

      response = JSON.parse(@session.get("/workflows?conditions=name=#{name}"))

      # barf if we got anything other than a single workflow
      fail(IOError, ERR[:too_many_workflows]) if response['total'] > 1
      fail(IOError, ERR[:no_workflow_found]) if response['total'] == 0

      workflow_id = nil
      workflow_name = nil
      response['link'][0]['attributes'].each do |a|
        workflow_id = a['value'] if a['name'].eql?('id')
        workflow_name = a['value'] if a['name'].eql?('name')
      end

      # Barf if we got this far and the workflow we found has a different
      # name than what we went looking for.
      fail(IOError, ERR[:wrong_workflow_wtf]) unless workflow_name.eql?(name)

      getWorkflowForId(workflow_id)
    end

  end

end
