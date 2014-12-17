require 'thor'
require 'vcoworkflows/version'
require 'vcoworkflows/constants'
require 'vcoworkflows/vcosession'
require 'vcoworkflows/workflowservice'
require 'vcoworkflows/workflow'
require 'vcoworkflows/workflowparameter'
require 'vcoworkflows/workflowtoken'
require 'vcoworkflows/cli/execute'
require 'vcoworkflows/cli/query'
# require 'vcoworkflows/cli/auth'

# rubocop:disable LineLength
# Refer to README.md for use instructions
module VcoWorkflows
  # Start of main CLI processing
  class CLI < Thor
    package_name 'vcoworkflows'
    map '--version' => :version
    map '-v' => :version

    desc 'version', DESC_VERSION
    def version
      puts VERSION
    end

    register(VcoWorkflows::Cli::Execute, 'execute', 'execute <WORKFLOW>', DESC_CLI_EXECUTE)
    register(VcoWorkflows::Cli::Query, 'query', 'query <WORKFLOW>', DESC_CLI_QUERY)
  end
end
# rubocop:enable LineLength
