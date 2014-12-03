require_relative 'constants'
require 'json'

module VcoWorkflows

  attr_reader :id
  attr_reader :name
  attr_reader :version
  attr_reader :description
  attr_reader :inParameters
  attr_reader :outParameters

  class Workflow

    def initialize(workflow_json: nil)

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

  end

end
