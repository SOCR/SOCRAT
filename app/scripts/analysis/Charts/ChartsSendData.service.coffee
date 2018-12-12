'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsSendData extends BaseService
  @inject 'app_analysis_charts_msgService'

  initialize: ->
    @msgService = @app_analysis_charts_msgService

  graphFormat: (chartData, graphInfo, dataType) ->
    console.log "dataType"
    console.log dataType

    if dataType is "NESTED" then return chartData
    else # dataType = "FLAT"
      obj = []
      len = chartData[0].length
      if graphInfo.y is "" and graphInfo.z is ""
        obj = (x: chartData[graphInfo.x][i].value for i in [0...len])
      else if graphInfo.y isnt "" and graphInfo.z is ""
        obj = for i in [0...len]
          x: chartData[graphInfo.x][i].value
          y:  chartData[graphInfo.y][i].value
      else
        obj = for i in [0...len]
          x:  chartData[graphInfo.x][i].value
          y:  chartData[graphInfo.y][i].value
          z:  chartData[graphInfo.z][i].value
      return obj

  createGraph: (chartData, graphInfo, headers, dataType, scheme_input) ->
    streamColor = scheme_input
    console.log streamColor

    send = @graphFormat chartData, graphInfo, dataType
    results =
      data: send
      vLab: headers[graphInfo.v],
      wLab: headers[graphInfo.w],
      xLab: headers[graphInfo.x],
      yLab: headers[graphInfo.y],
      zLab: headers[graphInfo.z],
      name: graphInfo.graph

    if graphInfo.graph is "Stream Graph"
      console.log("won't add property")
      results.scheme = streamColor

    @msgService.broadcast 'charts:graphDiv', results
