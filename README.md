# Vcoworkflows

`vcoworkflows` provides a Ruby API for finding and executing vCenter
Orchestrator workflows. You can search for a workflow either by name or
by GUID, populate the resulting `VcoWorkflows::Workflow` object's
`inputParameters` with the required values, and then request that the
the configured workflow be executed by vCenter Orchestrator.

Under the hood, communcations with vCenter Orchestrator is done via its
REST API, and all the REST heavy-lifting here is done by the fine and reliable
[`rest-client`](https://rubygems.org/gems/rest-client) gem. HTTP Basic
authentication is used with vCenter Orchestrator, and the username and
password can either be passed as command-line arguments or set as environment
variables (`$VCO_USER` and `$VCO_PASSWD`).


## Installation

`vcoworkflows` is distributed as a ruby gem.

Add this line to your application's Gemfile:

```ruby
gem 'vcoworkflows'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vcoworkflows

## Usage

[example.rb](example.rb):

```ruby
#!/usr/bin/env ruby

require 'vcoworkflows'

# What am I connecting to?
server = 'https://myvco.example.com:8281/'
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

# Set up our session credentials for vCO
session = VcoWorkflows::VcoSession.new(server,
                                       user: username,
                                       password: password,
                                       verify_ssl: false)

# Set up a WorkflowService which will broker our API calls
workflow_service = VcoWorkflows::WorkflowService.new(session)

# Get the workflow
workflow = workflow_service.get_workflow_for_name(workflow_name)

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
  # back again later. It's not done yet.
  unless wftoken.state.eql?('running') || wftoken.state.match(/waiting/)
    finished = true
    wftoken.output_parameters.each { |k, v| puts " #{k}: #{v}" }
  end
end
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vcoworkflows/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
