require_relative '../spec_helper.rb'
require 'vcoworkflows'

describe VcoWorkflows::WorkflowPresentation, 'WorkflowPresentation' do
  it 'should create the object' do
    workflow_presentation_json = '''
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
    wfp = VcoWorkflows::WorkflowPresentation.new(workflow_presentation_json, nil)
    expect(wfp.presentation_data).to eq(JSON.parse(workflow_presentation_json))
  end
end
