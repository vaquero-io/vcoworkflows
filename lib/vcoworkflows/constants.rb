module VcoWorkflows

  DESC_VERSION = 'Display the installed version of the VcoWorkflows gem'
  DESC_CLI_EXECUTE = 'Execute the specified workflow'
  DESC_CLI_EXECUTE_DRY_RUN = 'Dry run; do not actually execute the workflow.'
  DESC_CLI_EXECUTE_NAME = 'Name of the workflow to execute'
  DESC_CLI_EXECUTE_ID = 'GUID of the workflow to execute'
  DESC_CLI_EXECUTE_SERVER = 'VMware vCenter Orchestrator server URL'
  DESC_CLI_EXECUTE_USERNAME = 'vCO user name'
  DESC_CLI_EXECUTE_PASSWORD = 'vCO password'
  DESC_CLI_EXECUTE_VERIFY_SSL = 'Perform TSL Certificate verification'
  DESC_CLI_EXECUTE_PARAMETERS = 'Comma-separated list of key=value parameters for workflow'

  API_URL_BASE = '/vco/api'

  # error messages
  ERR = {
      wtf: 'vcoworkflows: I have no idea what just went wrong.',
      no_workflow_found: 'vcoworkflows: no workflow found!',
      too_many_workflows: 'vcoworkflows: more than one workflow found for given name!',
      wrong_workflow_wtf: 'vcoworkflows: search returned the wrong workflow! (?)',
      no_workflow_service_defined: 'vcoworkflows: Attempted to execute a workflow with a nil workflow service!',
      param_verify_failed: 'vcoworkflows: Attempt to verify required parameter failed!'
  }


end
