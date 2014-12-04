require "vcoworkflows/version"
require "vcoworkflows/constants"
require 'thor'

module VcoWorkflows
  # Your code goes here...

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
