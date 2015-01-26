require_relative '../spec_helper.rb'
require 'vcoworkflows'

describe VcoWorkflows::WorkflowParameter, 'WorkflowParameter' do

  before(:each) do
    @paramname = 'testparam'
    @paramtype = 'string'
    @paramvalue = 'squirrel!'
    @paramarray = %w{ a b c }
    @string_json = '''{"type":"string","name":"testparam","scope":"local","value":{"string":{"value":"squirrel!"}}}'''
    @array_json = '''{"type":"Array","name":"testparam","scope":"local","value":{"array":{"elements":[{"string":{"value":"a"}},{"string":{"value":"b"}},{"string":{"value":"c"}}]}}}'''
  end

  it 'should not be set' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: @paramtype)
    expect(wfp.set?).to eq(false)
  end

  it 'should be set when created with value' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: @paramtype,
                                              value: @paramvalue)
    expect(wfp.set?).to eq(true)
  end

  it 'should not be required' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: @paramtype)
    expect(wfp.required?).to eq(false)
  end

  it 'should be required' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: @paramtype,
                                              required: true)
    expect(wfp.required?).to eq(true)
  end

  it 'should be an array of strings' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: 'Array/string')
    expect(wfp.type).to eql('Array')
    expect(wfp.subtype).to eql('string')
  end

  it 'should be an array of strings ["a", "b", "c"]' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramnam,
                                              type: 'Array/string')
    wfp.set(@paramarray)
    expect(wfp.value).to eq([ 'a', 'b', 'c'])
  end

  it 'should generate a JSON document for single value' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: @paramtype,
                                              value: @paramvalue)
    expect(wfp.to_json).to eql(@string_json)
  end

  it 'should generate a JSON document for Array value' do
    wfp = VcoWorkflows::WorkflowParameter.new(name: @paramname,
                                              type: 'Array/string',
                                              value: @paramarray)
    expect(wfp.to_json).to eql(@array_json)
  end

end
