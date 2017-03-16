'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class DistList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Normal Distribution'
      value: 0
      x: ['integer', 'number', 'string']
      y: false
      z: false
      message: "This class designs a simple polynomial model fitting curve"
      xLabel: "Add x"

    ,
      name: 'Binomial Distribution'
      value: 1
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable and a y variable."
      xLabel: "Add x"

    ,
      name: 'Poisson Distribution'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: ""
    ,
      name: 'Polynomial Distribution'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple polynomial model fitting curve"
      xLabel: ""




    ]


