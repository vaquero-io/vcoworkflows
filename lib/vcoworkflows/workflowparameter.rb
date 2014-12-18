require_relative 'constants'
require 'json'

module VcoWorkflows
  # WorkflowParameter
  class WorkflowParameter
    attr_reader :name
    attr_reader :type
    attr_reader :subtype
    attr_reader :value
    attr_accessor :required

    # Public
    # @param [String] name - Name of the workflow parameter
    # @param [String] type - Data type of the parameter (according to vCO)
    # @param [Boolean] required - Whether or not the parameter is mandatory
    # @param [Object] value - the parameter value
    # @return [VcoWorkflows::WorkflowParameter]
    # rubocop:disable MethodLength
    def initialize(name: nil, type: nil, required: false, value: nil)
      @name = name
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
      # create an empty array. If it's not supposed to be an array, just
      # set the value, even if it's still nil.
      if @type.eql?('Array') && value.nil?
        @value = []
      else
        @value = set(value)
      end
    end
    # rubocop:enable MethodLength

    # Public
    # Set the parameter value
    # @param [Object] value - Value for the parameter
    # rubocop:disable CyclomaticComplexity
    def set(value)
      # TODO: Determine if we really need to bother with "simple" types
      # It might be enough to just concern ourselves with complex types
      # like 'Array/*'
      case @type
      when 'Array'
        fail(IOError, ERR[:param_verify_failed]) unless value.is_a?(Array)
      end unless value.nil?
      @value = value
    end
    # rubocop:enable CyclomaticComplexity

    # Public
    # Quickly determine if a value's been set
    # @return [Boolean]
    def set?
      case value.class
      when Array
        value.size == 0 ? false : true
      else
        value.nil? ? false : true
      end
    end

    # Public
    # Return a data structure version of this object
    # @return [Hash]
    # rubocop:disable LineLength, HashSyntax
    def as_struct
      attributes = { :type => @type, :name => @name, :scope => 'local' }

      # If the value is an array, we need to build it in the somewhat silly
      # manner that vCO requires it to be presented. Otherwise, just paste
      # it on the end of the hash.
      if @type.eql?('Array')
        fail(IOError, ERR[:wtf]) unless @value.is_a?(Array)
        attributes[:value] = { @type.downcase => { :elements => [] } }
        @value.each { |val| attributes[:value][@type.downcase][:elements] << { @subtype => { :value => val } } }
      else
        attributes[:value] = { @type => { :value => @value } }
      end

      # Assert
      attributes
    end
    # rubocop:enable LineLength, HashSyntax

    # Public
    # Return a string representation of the parameter
    # @return [String]
    # rubocop:disable CyclomaticComplexity, PerceivedComplexity, MethodLength
    def to_s
      string = "#{@name}"
      # If value is either nil or an empty array
      if @value.nil? || @value.is_a?(Array) && @value.size == 0
        string << " (#{@type}"
        string << "/#{@subtype}" if @subtype
        string << ')'
        string << ' [required]' if @required
      else
        if @type.eql?('Array')
          string << ' ='
          @value.each { |v| string << "\n  - #{v}" }
        else
          string << " = #{@value}"
        end
      end
      string << "\n"
    end
    # rubocop:enable CyclomaticComplexity, PerceivedComplexity, MethodLength

    # Public
    # Return a JSON document representation of this object
    # @return [String]
    def to_json
      as_struct.to_json
    end
  end
end
