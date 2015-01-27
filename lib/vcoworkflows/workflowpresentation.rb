require_relative 'constants'
require_relative 'workflowservice'
require_relative 'workflow'
require_relative 'workflowtoken'
require_relative 'workflowparameter'
require 'json'

# VcoWorkflows
module VcoWorkflows
  # rubocop:disable ClassLength

  # WorkflowPresentation is a helper class for Workflow and is primarily used
  # internally to apply additional constraints to WorkflowParameters. Currently
  # WorkflowPresentation examines the presentation JSON from vCO to determine
  # whether input parameters for the workflow are required or not.
  class WorkflowPresentation
    attr_reader :presentation_data
    attr_reader :source_json

    alias_method :source_json, :to_json

    # rubocop:disable LineLength, MethodLength

    # Create a new WorkflowPresentation
    # @param [String] presentation_json JSON response body from vCO
    # @param [VcoWorkflows::Workflow] workflow Workflow object to apply presentation to
    # @return [VcoWorkflows::WorkflowPresentation]
    def initialize(presentation_json, workflow)
      @source_json = presentation_json
      @workflow = workflow
      @presentation_data = JSON.parse(presentation_json)
    end

    # Apply the workflow presentation to the workflow
    def apply
      # We're parsing this because we specifically want to know if any of
      # the input parameters are marked as required. This is very specifically
      # in the array of hashes in:
      # presentation_data[:steps][0][:step][:elements][0][:fields]
      fields = @presentation_data['steps'][0]['step']['elements'][0]['fields']

      fields.each do |attribute|
        next unless attribute.key?('constraints')
        attribute['constraints'].each do |const|
          if const.key?('@type') && const['@type'].eql?('mandatory')
            @workflow.input_parameters[attribute['id']].required
          end
        end
      end
    end
    # rubocop:enable LineLength, MethodLength

    # @return [String]
    def to_s
      JSON.pretty_generate(JSON.parse(@source_json))
    end
  end

  # rubocop:enable ClassLength

end
