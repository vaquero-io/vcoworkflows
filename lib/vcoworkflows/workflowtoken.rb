require_relative 'constants'
require_relative 'workflow'
require_relative 'workflowservice'

module VcoWorkflows

  class WorkflowToken

    attr_reader :id
    attr_reader :title
    attr_reader :workflow_id
    attr_reader :current_item_name
    attr_reader :current_item_state
    attr_reader :global_state
    attr_reader :start_date
    attr_reader :end_date
    attr_reader :xml_content

    def initialize(token_json)

    end

  end

end
