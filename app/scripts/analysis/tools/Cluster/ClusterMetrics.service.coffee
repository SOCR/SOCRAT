'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterMetrics extends BaseModuleDataService

  initialize: ->

    @metrics = [
      name: 'Euclidean'
      method: @euclidean
    ,
      name: 'Manhattan'
      method: @manhattan
    ,
      name: 'Maximum'
      method: @max
    ,
      name: 'Mahalanobis'
      method: @mahalanobis
    ]

  euclidean: (v1, v2) ->
    total = 0
    for i in [0..v1.length - 1]
      total += Math.pow(v2[i] - v1[i], 2)
    Math.sqrt(total)

  manhattan: (v1, v2) ->
    total = 0
    for i in [0..v1.length - 1]
      total += Math.abs(v2[i] - v1[i]);
    total

  max: (v1, v2) ->
    max = 0
    for i in [0..v1.length - 1]
      max = Math.max(max , Math.abs(v2[i] - v1[i]));
    max

  mahalanobis: (v1, v2, s) ->
    if s
      l = v1.length
      invCov = s
      diff = (v1[k] - v2[k] for k in [0..l - 1])
      total = 0
      for row, i in invCov
        for el, j in row
          total += invCov[i][j] * Math.pow(diff[i], 2 - i - j) * Math.pow(diff[j], i + j)
      Math.sqrt(total)
    else
      false

  getNames: ->
    @metrics.map (metric) -> metric.name

  distance: (v1, v2, type) ->
    (@metrics.filter (metric) -> metric.name.toLowerCase() is type.toLowerCase()).shift().method(v1, v2)
