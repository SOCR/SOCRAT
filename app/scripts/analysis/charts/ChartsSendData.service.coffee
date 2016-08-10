'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsSendData extends BaseService

_createGraph: (chartData, graphInfo, headers, $rootScope, dataType, scheme_input) ->
  graphFormat: () ->
    console.log "dataType"
    console.log dataType

    if dataType is "NESTED" then return chartData
    else # dataType = "FLAT"
      obj = []
      len = chartData[0].length
      if graphInfo.y is "" and graphInfo.z is ""
        obj = []
        for i in [0...len] by 1
          tmp =
            x:  chartData[graphInfo.x][i].value
          obj.push tmp
      else if graphInfo.y isnt "" and graphInfo.z is ""
        obj = []
        for i in [0...len] by 1
          tmp =
            x:  chartData[graphInfo.x][i].value
            y:  chartData[graphInfo.y][i].value
          obj.push tmp
      else
        obj = []

        for i in [0...len] by 1
          tmp =
            x:  chartData[graphInfo.x][i].value
            y:  chartData[graphInfo.y][i].value
            z:  chartData[graphInfo.z][i].value
          obj.push tmp
      return obj

  streamColor = scheme_input
  console.log streamColor

  send = graphFormat()
  results =
    data: send
    xLab: headers[graphInfo.x],
    yLab: headers[graphInfo.y],
    zLab: headers[graphInfo.z],
    name: graphInfo.graph

  if graphInfo.graph is "Stream Graph"
    console.log("won't add property")
    results.scheme = streamColor


  $rootScope.$broadcast 'charts:graphDiv', results
