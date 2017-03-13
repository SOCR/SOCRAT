'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class DistList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Normal Distribution'
      value: 0
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Binomial Distribution'
      value: 1
      x: ['integer', 'number']
      y: ['integer', 'number']
      z: false
      message: "Choose an x variable and a y variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Poisson Distribution'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: ""


    ]


