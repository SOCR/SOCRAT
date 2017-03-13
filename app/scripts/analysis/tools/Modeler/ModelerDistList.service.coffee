'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class DistList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Normal Dist'
      value: 0
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,

    ]


