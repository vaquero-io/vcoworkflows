require 'thor'
require 'vcoworkflows/version'
require 'vcoworkflows/constants'
require 'vcoworkflows/vcosession'
require 'vcoworkflows/workflowservice'
require 'vcoworkflows/workflow'
require 'vcoworkflows/workflowparameter'
require 'vcoworkflows/workflowtoken'

module VcoWorkflows

  class CLI < Thor

    package_name 'vcoworkflows'
    map '--version' => :version
    map '-v' => :version

    desc 'version', DESC_VERSION
    def version
      puts VERSION
    end

  end

end
