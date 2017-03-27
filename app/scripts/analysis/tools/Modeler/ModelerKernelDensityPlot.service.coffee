'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name:
  @type: service
  @desc: Performs spectral clustering using NJW algorithm

###

module.exports = class KernelDensityPlot extends BaseService

  initialize: () ->






  kernelDensityEstimator: (kernel, x) ->
  (sample) ->
    x.map (x) ->
      [
        x
        d3.mean(sample, (v) ->
          kernel( x - v)
        )
      ]



  epanechnikovKernel: (bandwith) ->
  (u) ->
#return Math.abs(u /= bandwith) <= 1 ? .75 * (1 - u * u) / bandwith : 0;
    if Math.abs(u = u / bandwith) <= 1
      0.75 * (1 - (u * u)) / bandwith
    else
      0



