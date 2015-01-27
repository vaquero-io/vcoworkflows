require_relative '../spec_helper.rb'
require 'vcoworkflows'

# rubocop:disable LineLength

describe VcoWorkflows::Workflow, 'Workflow' do
  before(:each) do
    @workflow_json = '''
    {
      "output-parameters": [
        {
          "name": "vms",
          "type": "Array/VC:VirtualMachine",
          "description": "Virtual machines found"
        }
      ],
      "relations": {
        "link": [
          {
            "rel": "up",
            "href": "https://vcoserver.example.com:8281/vco/api/inventory/System/Workflows/Library/vCenter/Virtual%2BMachine%2Bmanagement/Basic/"
          },
          {
            "rel": "executions",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/executions/"
          },
          {
            "rel": "presentation",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/presentation/"
          },
          {
            "rel": "tasks",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/tasks/"
          },
          {
            "rel": "icon",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/icon/"
          },
          {
            "rel": "schema",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/schema/"
          },
          {
            "rel": "permissions",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/permissions/"
          },
          {
            "rel": "interactions",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/interactions/"
          }
        ]
      },
      "id": "BB808080808080808080808080808080A180808001322751030482b80adf61e7c",
      "name": "Get virtual machines by name",
      "version": "0.1.0",
      "description": "Returns a list of virtual machines from all registered vCenter Server hosts that match the provided expression.",
      "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/",
      "customized-icon": false,
      "input-parameters": [
        {
          "name": "criteria",
          "type": "string",
          "description": "Search criteria. Regular expressions supported."
        }
      ]
    }
    '''

    @workflow_presentation_json = '''
    {
      "output-parameters": [
        {
          "name": "criteria",
          "type": "string",
          "description": "Search criteria. Regular expressions supported."
        }
      ],
      "input-parameters": [
        {
          "name": "criteria",
          "type": "string",
          "description": "Search criteria. Regular expressions supported."
        }
      ],
      "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/presentation/",
      "name": "Get virtual machines by name",
      "id": "BB808080808080808080808080808080A180808001322751030482b80adf61e7c",
      "steps": [
        {
          "step": {
            "messages": [],
            "hidden": false,
            "elements": [
              {
                "fields": [
                  {
                    "display-name": "Search criteria. Regular expressions supported.",
                    "constraints": [],
                    "@type": "field",
                    "fields": [],
                    "id": "criteria",
                    "description": "Search criteria. Regular expressions supported.",
                    "hidden": false,
                    "messages": [],
                    "decorators": [],
                    "type": "string"
                  }
                ],
                "messages": [],
                "hidden": false,
                "@type": "group"
              }
            ]
          }
        }
      ],
      "relations": {
        "link": [
          {
            "rel": "up",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/"
          },
          {
            "rel": "instances",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/presentation/instances/"
          },
          {
            "rel": "add",
            "href": "https://vcoserver.example.com:8281/vco/api/workflows/BB808080808080808080808080808080A180808001322751030482b80adf61e7c/presentation/instances/"
          }
        ]
      }
    }
    '''
  end

  it 'should parse parameters correctly' do
    parameters = VcoWorkflows::Workflow.parse_parameters(JSON.parse(@workflow_json)['input-parameters'])
    expect(parameters.size).to eq(1)
    expect(parameters['criteria'].type).to eql('string')
    expect(parameters['criteria'].subtype).to eq(nil)
    expect(parameters['criteria'].set?).to eq(false)
  end

  it 'should create a workflow object' do
    wfs = VcoWorkflows::WorkflowService.new(nil)
    wfp = VcoWorkflows::WorkflowPresentation.new(@workflow_presentation_json, nil)
    wfs.stub get_presentation: @workflow_presentation_json
  end
end

# rubocop:enable LineLength
