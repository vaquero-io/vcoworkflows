# Vcoworkflows

[![Build Status](https://travis-ci.org/ActiveSCM/vcoworkflows.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/ActiveSCM/vcoworklfows.png?travis)][gemnasium]
[![Coverage Status](https://coveralls.io/repos/ActiveSCM/vcoworkflows/badge.svg)](https://coveralls.io/r/ActiveSCM/vcoworkflows)
[![Inline docs](http://inch-ci.org/github/ActiveSCM/vcoworkflows.png?branch=master)][inch]

[travis]: http://travis-ci.org/ActiveSCM/vcoworkflows
[gemnasium]: https://gemnasium.com/ActiveSCM/vcoworkflows
[coveralls]: https://coveralls.io/r/ActiveSCM/vcoworkflows
[inch]: http://inch-ci.org/github/ActiveSCM/vcoworkflows


**This gem is in very early development stages, and as such, may change
incompatibly as we work towards our first release.**

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

## Requirements

- [rest-client](https://github.com/rest-client/rest-client) is used for all the
communications with vCenter Orchestrator.
- [thor](http://whatisthor.com) is used for the command-line utilities.

The only external dependency is vCenter Orchestrator.

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

Quick example:

```ruby
require 'vcoworkflows'
my_workflow = VcoWorkflows::Workflow.new(
    'Request Component,
    url: 'https://vco.example.com:8281/vco/api',
    username: 'jdoe',
    password: 's3cr3t',

)

```

All the necessary interactions with a Workflow in vCenter Orchestrator are
available via the [`VcoWorkflows::Workflow`](lib/vcoworkflows/Workflow.rb)
class.

### Selecting a Workflow

It is possible to select a Workflow by GUID (as divined by the vCenter
Orchestrator client) or by specifying the Workflow's name. If specifying by
name, however, an exeption will be raised if either no workflows are found,
or multiple workflows are found. Therefor, GUID is likely "safer". In either
case, however, the workflow name must be given, as in the example above.

Selecting a workflow by GUID is done by adding the `id:` parameter when
creating a new `Workflow` object:

```ruby
my_workflow = VcoWorkflows::Workflow.new(
    'Request Component,
    id: '6e04a460-4a45-4e16-9603-db2922c24462',
    url: 'https://vco.example.com:8281/vco/api',
    username: 'jdoe',
    password: 's3cr3t',
    verify_ssl: false
)
```

### Executing a workflow

To execute a workflow, set any input parameters to appropriate values (if
required), then send call `execute`. This will return an execution ID from
vCenter Orchestrator, which identifies the run you have requested. The
execution ID is also preserved in the `Workflow` object for simplicity.

```ruby
input_parameters = { 'name'    => 'a string value',
                     'version' => '2',
                     'words'   => %w(fe fi fo fum) }
# ...
input_parameters.each { |k, v| workflow.set_parameter(k, v) }
workflow.execute
```

### Checking an execution status

You can then get a Workflow Token from the Workflow, which will contain
state and result information for the execution.

```ruby
wf_token = workflow.token(workflow.execute)
```

The `WorkflowToken` can be used to determine the current state and disposition
of a Workflow execution. This can be used to periodically check up on the
execution, if you want to follow its status:

```ruby
finished = false
until finished
  sleep 5
  # Fetch a new workflow token to check the status of the workflow execution
  wftoken = workflow.token
  # If the execution is no longer alive, exit the loop and report the results.
  unless wftoken.alive?
    finished = true
    wftoken.output_parameters.each { |k, v| puts " #{k}: #{v}" }
  end
end
```

### Fetching the execution log

For any workflow execution, you can fetch the log:

```ruby
workflow.execute
# ... some time later
log = workflow.log
puts log
```

If you have the execution ID from a previous execution:

```ruby
log = workflow.log(execution_id)
puts log
```

### Querying a Workflow from the command line

The `vcoworkflows` command line allows you to query a vCO server for a
workflow, as well as executions and details on a specific execution.

```
$ vcoworkflows query "Request Component" \
    --server=https://vco.example.com:8281/

Retrieving workflow 'Request Component' ...

Workflow:    Request Component
ID:          6e04a460-4a45-4e16-9603-db2922c24462
Description:
Version:     0.0.33

Input Parameters:
 coreCount (string) [required]
 ramMB (string) [required]
 onBehalfOf (string) [required]
 machineCount (string) [required]
 businessUnit (string) [required]
 reservation (string) [required]
 location (string) [required]
 environment (string) [required]
 image (string) [required]
 runlist (Array/string) [required]
 nodename (string) [required]
 component (string) [required]
 attributesJS (string) [required]

Output Parameters:
 result (string) [required]
 requestNumber (number) [required]
 requestCompletionDetails (string) [required]
```

You can also retrieve a full list of executions, or only the last N:

```
$ vcoworkflows query "Request Component" \
    --server=https://vco.example.com:8281/ \
    --executions --last 5

Retrieving workflow 'Request Component' ...


Workflow:   Request Component
ID:           6e04a460-4a45-4e16-9603-db2922c24462
Description:
Version:      0.0.33

Executions:
2014-12-19T20:38:18.457Z [ff8080814a1cb55c014a6445b85b7714] completed
2014-12-19T20:49:04.087Z [ff8080814a1cb55c014a644f925577cf] completed
2014-12-19T21:00:25.587Z [ff8080814a1cb55c014a6459f87278c0] completed
2014-12-19T21:25:04.170Z [ff8080814a1cb55c014a64708829797f] completed
2014-12-19T21:43:46.833Z [ff8080814a1cb55c014a6481a9927a78] completed
```

To get the logs from a specific execution:

```
vcoworkflows query "Request Component" \
    --server=https://vco.example.com:8281/ \
    --execution-id ff8080814a1cb55c014a6481a9927a78 \
    --log

Retrieving workflow 'Request Component' ...

Fetching data for execution ff8080814a1cb55c014a6481a9927a78...

Execution ID:      ff8080814a1cb55c014a6481a9927a78
Name:              Request Component
Workflow ID:       6e04a460-4a45-4e16-9603-db2922c24462
State:             completed
Start Date:        2014-12-19 13:43:46 -0800
End Date:          2014-12-19 13:55:24 -0800
Started By:        user@example.com

Input Parameters:
 coreCount = 2
 ramMB = 2048
 onBehalfOf = service_account@example.com
 machineCount = 1
 businessUnit = aw
 reservation = nonprodlinux
 location = us_east
 environment = dev1
 image = centos-6.6-x86_64-20141203-1
 runlist =
  - role[base]
  - role[api]
 nodename =
 component = api
 attributesJS =

Output Parameters:
 result = SUCCESSFUL
 requestNumber = 326.0
 requestCompletionDetails = Request succeeded. Created vm00378.

2014-12-19 13:43:46 -0800 info: gruiz-ade: Workflow 'Request Component' has started
2014-12-19 13:43:59 -0800 info: gruiz-ade: Workflow is paused; Workflow 'Request Component' has paused while waiting on signal
2014-12-19 13:55:23 -0800 info: gruiz-ade: Workflow 'Request Component' has resumed
2014-12-19 13:55:24 -0800 info: gruiz-ade: Workflow 'Request Component' has completed
```

## Contributing

1. Fork it ( https://github.com/ActiveSCM/vcoworkflows/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### License and Authors

- [Gregory Ruiz-Ade](https://github.com/gkra)

```
Copyright 2014 Active Network, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

