#!/usr/bin/env ruby
require 'vcoworkflows'
require 'vcoworkflows/cli/auth'

# ===================================================================
# Variables
# ===================================================================

server = 'https://vcoserver.example.com:8281/'
workflow = 'Request Component'

# How many machine of each type will we build?
num_machines = 1
do_named = false
do_serialized = true

# Template build parameters for both named nodes and normal nodes
build_parameters = { 'coreCount' => '2',
                     'ramMB' => '2048',
                     'businessUnit' => 'aw',
                     'reservation' => 'nonprodlinux',
                     'environment' => 'dev1',
                     'image' => 'centos-6.6-x86_64',
                     'component' => 'webserver',
                     'onBehalfOf' => 'someuser@example.com',
                     'location' => 'us_east',
                     'runlist' => %w(role[base] role[applicaton]),
                     'machineCount' => '1' }

# Check interval
check_sleep = 15

# Generate named nodes for example
spec_nodes = []
1.upto(num_machines) { |i| spec_nodes << sprintf("dev1-order-%02de", i) } if do_named

# ===================================================================
# Create a Provisioner class to manage the connection and give us
# wrapper for common provisioning tasks...
#
# Initialize with a server URL, and optionally an auth object, then
# use provision_nodes to do the work.
#
# rubocop:disable LineLength
class Provisioner
  attr_reader :workflow_service

  # Public
  # If we're not given an auth object, create a default one that pulls
  # from the environment.
  #
  # @param [String] server - server URL for vCenter Orchestrator
  # @param [VcoWorkflows::Cli::Auth] auth - Authentication object
  #
  def initialize(server = nil, auth = VcoWorkflows::Cli::Auth.new)
    session = VcoWorkflows::VcoSession.new(server,
                                           user: auth.username,
                                           password: auth.password,
                                           verify_ssl: false)
    @workflow_service = VcoWorkflows::WorkflowService.new(session)
  end

  # Public
  # Provision some nodes. Take the workflow object, and our parameters hash,
  # set all the workflow's input parameters, and execute the workflow.
  #
  # @param [VcoWorkflows::Workflow] workflow - Workflow object
  # @param [Hash] parameters - input parameters in Hash form
  # @return [VcoWorkflows::WorkflowToken]
  #
  # rubocop:disable MethodLength
  def provision_nodes(workflow = nil, parameters = nil)
    # Set the parameters in the workflow
    puts 'Setting workflow input parameters...'
    parameters.each do |k, v|
      # puts "setting #{k} to #{v}"
      workflow.set_parameter(k, v)
    end

    puts 'Verifying required parameters are present...'
    workflow.verify_parameters

    puts 'Executing workflow...'
    wftoken = workflow.execute
    parameters.key?('nodename') ? node = parameters['nodename'] : node = "#{parameters['machineCount']} node(s)"
    puts "Provisioning #{node} with \"#{workflow.name}\" (#{workflow.id}/#{wftoken.id})"
    wftoken.id
  end
  # rubocop:enable MethodLength
end
# rubocop:enable LineLength

# ===================================================================
#
# Main
#
# ===================================================================

# Timekeeping
starttime = Time.now

# Create our provisioner
# Don't bother with auth, we'll pull from the environment
prov = Provisioner.new(server)

# Create our list of running jobs
@running_jobs = []

# ===================================================================
# "named" nodes (i.e., the Chef Node Name is specified in the build)
#
puts "\nProvisioning named nodes (#{spec_nodes.join(', ')})...\n" if spec_nodes.size > 0
spec_nodes.each do |node|
  # Get the workflow
  puts 'Fetching workflow...'
  wf = prov.workflow_service.get_workflow_for_name(workflow)

  # Copy the build parameters and set nodename
  parameters = build_parameters.dup
  parameters['machineCount'] = '1'
  parameters['nodename'] = node
  @running_jobs << prov.provision_nodes(wf, parameters)
end

# ===================================================================
# "normal" nodes (i.e., we don't care what they're named)
#
if do_serialized
  puts "\nProvisioning serialized nodes...\n"
  wf = prov.workflow_service.get_workflow_for_name(workflow)
  build_parameters['machineCount'] = num_machines
  @running_jobs << prov.provision_nodes(wf, build_parameters)
end

# ===================================================================
# Wait for all the requested workflows to complete
#
puts 'Waiting for the following executions to complete:'
@running_jobs.each { |id| puts " - #{id}" }

while @running_jobs.size > 0
  sleep check_sleep
  puts "\nChecking on running workflows (#{Time.now})..."
  @running_jobs.each do |id|
    wftoken = prov.workflow_service.get_execution(wf.id, id)
    print " - #{id} #{wftoken.state}"
    if wftoken.state.eql?('running') || wftoken.state.match(/waiting/)
      puts ''
    else
      puts "; Run time #{(wftoken.end_date - wftoken.start_date) / 1000} seconds"
      @running_jobs.delete(id)
      wftoken.output_parameters.each do | k, v |
        puts " #{k}: #{v}"
      end
    end
  end
end

endtime = Time.now

puts ''
puts 'All workflows completed.'
puts "Started:  #{starttime}"
puts "Finished: #{endtime}"
puts "Total #{sprintf("%2f", endtime - starttime)} seconds"
