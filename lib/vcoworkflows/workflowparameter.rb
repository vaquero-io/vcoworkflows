require_relative 'constants'
require 'json'

module VcoWorkflows
  class WorkflowParameter

    attr_reader :name
    attr_reader :type
    attr_reader :subtype
    attr_reader :value

    attr_accessor :required

    # Public
    # @param [String] name - Name of the workflow parameter
    # @param [String] type - Data type of the parameter (according to vCO)
    # @param [Boolean] required - Whether or not the parameter is mandatory for the workflow
    # @param [Object] value - the parameter value
    # @return [VcoWorkflows::WorkflowParameter]
    def initialize(name: nil, type: nil, required: false, value: nil)
      @name = name

      # set the type properly
      case type
      when /\//
        @type = type.gsub(/\/.*$/, '')
        @subtype = type.gsub(/^.*\//, '')
      else
        @type = type
        @subtype = nil
      end

      @required = required

      # If value is supposed to be an array but we dont' have a value yet,
      # create an empty array
      if @type.eql?('Array') && value.nil?
        @value = []
      else
        @value = value
      end
    end

    # Public
    # Set the parameter value
    # @param [Object] value - Value to set the parameter to
    def set(value)
      case @input_parameters[parameter].type
        when 'Array'
          fail(IOError, ERR[:param_verify_failed]) unless value.is_a?(Array)
        when 'string'
          fail(IOError, ERR[:param_verify_failed]) unless value.is_a?(Array)
        when 'number'
          fail(IOError, ERR[:param_verify_failed]) unless value.is_a?(Array)
      end
      @value = value
    end

    # Public
    # Return a data structure version of this object
    # @return [Hash]
    def as_struct
      attributes = {:type => @type, :name => @name, :scope => 'local'}

      # If the value is an array, we need to build it in the somewhat silly
      # manner that vCO requires it to be presented. Otherwise, just paste
      # it on the end of the hash.
      if @type.eql?('Array')
        fail(IOError, ERR[:wtf]) unless @value.is_a?(Array)
        attributes[:value] = {@type => {:elements => []}}
        @value.each { |val| attributes[:value][@type][:elements] << {@subtype => {:value => val}} }
      else
        attributes[:value] = {@type => {:value => @value}}
      end

      return attributes
    end

    # Public
    # Return a JSON document representation of this object
    # @return [String]
    def to_json
      self.as_struct.to_json
    end

  end
end
