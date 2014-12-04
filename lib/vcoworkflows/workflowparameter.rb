require_relative 'constants'
require 'json'

module VcoWorkflows
  class WorkflowParameter

    attr_accessor :name
    attr_accessor :type
    attr_accessor :required
    attr_accessor :value

    def initialize(name: nil, type: nil, required: false, value: nil)
      @name = name unless name.nil?
      @type = type unless type.nil?
      @required = required
      @value = value
    end

    def as_struct
      attributes = {:type => @type,
                    :name => @name,
                    :scope => 'local',
                    :value => {@type => {:value => @value}}}
      return attributes
    end

    def to_json
      self.as_struct.to_json
    end

  end
end
