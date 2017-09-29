'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class DistList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Normal'
      value: 0
      x: ['integer', 'number', 'string']
      y: false
      z: false
      message: "This class models a normal distribution fitting curve to the dataset"
      xLabel: "Add x"

    ,
      name: 'Binomial'
      value: 1
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable and a y variable."
      xLabel: "Add x"

    ,
      name: 'Poisson'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: ""
    ,
      name: 'Polynomial'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple polynomial model fitting curve"
      xLabel: ""
    ,
    
      name: 'Kernel'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple polynomial model fitting curve"
      xLabel: ""
  



    ]


