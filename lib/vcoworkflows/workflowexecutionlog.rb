require_relative 'workflowservice'
require 'json'

# VcoWorkflows
module VcoWorkflows
  # WorkflowExecutionLog
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
    # rubocop:disable MethodLength, LineLength
    def to_s
      message = ''
      @messages.keys.sort.each do |timestamp|
        message << "#{Time.at(timestamp / 1000)}"
        message << " #{@messages[timestamp]['severity']}: #{@messages[timestamp]['user']}:"
        message << " #{@messages[timestamp]['short-description']}"
        unless @messages[timestamp]['short-description'].eql?(@messages[timestamp]['long-description'])
          message << "; #{@messages[timestamp]['long-description']}"
        end
        message << "\n"
      end

      # Assert
      message
    end
    # rubocop:enable MethodLength, LineLength
  end
end
