module VcoWorkflows

  DESC_VERSION = 'Display the installed version of the VcoWorkflows gem'

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
