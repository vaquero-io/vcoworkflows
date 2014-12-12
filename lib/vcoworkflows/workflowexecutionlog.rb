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
      JSON.parse(log_json)['logs'].each do |log_entry|
        messages[log_entry['entry']['time-stamp']] = log_entry['entry']
      end
    end

    # Public
    # @return [String]
    def to_s
      message = "Workflow execution log:\n"
      @messages.keys.sort.each do |timestamp|
        message << "#{Time.at(timestamp/1000)}"
        message << " #{@messages[timestamp]['severity']}: #{@messages[timestamp]['user']}:"
        message << " #{@messages[timestamp]['short-description']}"
        unless @messages[timestamp]['short-description'].eql?(@messages[timestamp]['long-description'])
          message << "; #{@messages[timestamp]['long-description']}"
        end
        message << "\n"
      end
      return message
    end

  end

end
