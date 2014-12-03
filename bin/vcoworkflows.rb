#!/usr/bin/env ruby

require 'vcoworkflows/runner'

VcoWorkflows::Runner.new(ARGV.dup).execute!
