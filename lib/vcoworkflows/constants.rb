module VcoWorkflows

  DESC_VERSION = 'Display the installed version of the VcoWorkflows gem'

  API_URL_BASE = '/vco/api'

  API_URL_WORKFLOWS = API_URL_BASE << '/workflows'

  # error messages
  ERR = {
      no_workflow_found: 'vcoworkflows: no workflow found!',
      too_many_workflows: 'vcoworkflows: more than one workflow found for given name!'
  }


end
