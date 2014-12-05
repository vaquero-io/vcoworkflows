require_relative 'constants'
require_relative 'workflow'
require_relative 'workflowservice'

module VcoWorkflows

  class WorkflowToken

    # "id": "ff80808148eb0494014a1c6314703d1d"
    # "state": "running"
    # "name": "Request Component"
    # "href": "https://meorcpoc0001.dev.activenetwork.com:8281/vco/api/workflows/6e04a460-4a45-4e16-9603-db2922c24462/executions/ff80808148eb0494014a1c6314703d1d/"
    # "start-date": 1417815463023
    # "started-by": "gruiz-ade@DEV.ACTIVENETWORK.COM"
    # "current-item-display-name": "__item-undefined__"

    attr_reader :id
    attr_reader :workflow_id
    attr_reader :name
    attr_reader :state
    attr_reader :href
    attr_reader :start_date
    attr_reader :end_date
    attr_reader :started_by
    attr_reader :current_item_name
    attr_reader :current_item_state
    attr_reader :content_exception
    attr_reader :global_state
    attr_reader :json_content

    def initialize(token_json, workflow_id)

      @json_content = token_json
      @workflow_id = workflow_id

      token = JSON.parse(token_json)

      @id                 = token.key?('id')                        ? token['id']                        : nil
      @name               = token.key?('name')                      ? token['name']                      : nil
      @state              = token.key?('state')                     ? token['state']                     : nil
      @href               = token.key?('href')                      ? token['href']                      : nil
      @start_date         = token.key?('start-date')                ? token['start-date']                : nil
      @end_date           = token.key?('end-date')                  ? token['end-date']                  : nil
      @started_by         = token.key?('started-by')                ? token['started-by']                : nil
      @current_item_name  = token.key?('current-item-display-name') ? token['current-item-display-name'] : nil
      @current_item_state = token.key?('current-item-state')        ? token['current-item-state']        : nil
      @global_state       = token.key?('global-state')              ? token['global-state']              : nil
      @content_exception  = token.key?('content-exeption')          ? token['content-exception']         : nil

    end

  end

end
