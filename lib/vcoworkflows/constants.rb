module VcoWorkflows

  DESC_VERSION = 'Display the installed version of the VcoWorkflows gem'

  API_URL_BASE = '/vco/api'

  # error messages
  ERR = {
      no_workflow_found: 'vcoworkflows: no workflow found!',
      too_many_workflows: 'vcoworkflows: more than one workflow found for given name!',
      wrong_workflow_wtf: 'vcoworkflows: search returned the wrong workflow! (?)',
      no_workflow_service_defined: 'vcoworkflows: Attempted to execute a workflow with a nil workflow service!'
  }


end
