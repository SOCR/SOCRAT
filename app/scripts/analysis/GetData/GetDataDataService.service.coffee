'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class GetDataDataService extends BaseModuleDataService
  @inject '$q', 'app_analysis_getData_msgService'

  # requires renaming message service injection to @msgService
  initialize: () ->
    @msgManager = @app_analysis_getData_msgService
    @getDataRequest = @msgManager.getMsgList().outgoing[0]
    @getDataResponse = @msgManager.getMsgList().incoming[0]
    @saveDataMsg = @msgManager.getMsgList().outgoing[1]

  getSummary: (data) ->
    @post(@msgManager.getMsgList().outgoing[2], @msgManager.getMsgList().incoming[2], data)

  inferTypes: (data) ->
    @post(@msgManager.getMsgList().outgoing[3], @msgManager.getMsgList().incoming[3], data)

  transformTypes: (dataFrame, types) ->
    if types? and dataFrame?    
      Object.keys(types).forEach (type)=>
        dataFrame.data.forEach (dataRow)=>
          switch types[type]
            when "number" then dataRow[type] = parseFloat dataRow[type]

            when "boolean" then dataRow[type] = ( dataRow[type] == 'true')

    dataFrame

  getHistogram: (data)->
    @post(@msgManager.getMsgList().outgoing[4], @msgManager.getMsgList().incoming[4], data) 

