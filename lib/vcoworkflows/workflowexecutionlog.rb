require_relative 'workflowservice'
require 'json'

module VcoWorkflows

  class WorkflowExecutionLog

    attr_reader :messages

    # Public
    #
    # @param [String] log_json - JSON document as string
    def initialize(log_json)
      @messages = {}
      JSON.parse(log_json).each do |log|
        @messages[log['entry']['time-stamp']] = log['entry']
      end
    end

  end

end
