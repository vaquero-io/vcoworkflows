#!/usr/bin/env ruby

require 'vcoworkflows'

# What am I connecting to?
url = 'https://myvco.example.com:8281/vco/api'
username = 'myuser'
password = 'secret!'

# What's the workflow I want to work with?
workflow_name = 'Do Something Cool'

# Define the parameters for the workflow which we need to supply.
# The 'Do Something Cool' workflow needs a name, version, and words (an array
# of strings).
input_parameters = { 'name'    => 'a string value',
                     'version' => '2',
                     'words'   => %w(fe fi fo fum) }

# Fetch the workflow from vCO
workflow = VcoWorkflows::Workflow.new(workflow_name,
                                      url: url,
                                      username: username,
                                      password: password,
                                      verify_ssl: false)

# Set the parameters in the workflow
input_parameters.each { |k, v| workflow.set_parameter(k, v) }

# Make sure we didn't miss any required input parameters
workflow.verify_parameters

# Execute the workflow. This gives us a `VcoWorkflows::WorkflowToken` object
# back, which has the information we need to check up on this execution later.
wftoken = workflow.execute

# We're going to wait around until the execution is done, so we'll check
# on it every 5 seconds until we see whether it completed or failed.
finished = false
until finished
  sleep 5
  # Fetch a new workflow token to check the status of the workflow execution
  wftoken = worflow_service.get_execution(workflow.id, wftoken.id)
  # If the state is 'running' or starts with 'waiting', we'll need to check
  # back again later. It's not done yet. Otherwise, dump out the results.
  unless wftoken.state.eql?('running') || wftoken.state.match(/waiting/)
    finished = true
    wftoken.output_parameters.each { |k, v| puts " #{k}: #{v}" }
  end
end
