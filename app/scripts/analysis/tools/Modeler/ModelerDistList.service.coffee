'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class DistList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Normal'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a normal distribution fitting curve to the dataset"
      xLabel: "Add x"

    ,
      name: 'Maxwell-Boltzman'
      value: 1
      x: ['integer', 'number']
      y: false
      z: false
      message: "Maxwell Boltzman distribution."
      xLabel: "Add x"

    ,
      name: 'Cauchy'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: ""
    ,
      name: 'Laplace'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple Laplace model fitting curve"
      xLabel: ""
    ,

      name: 'Exponential'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple Exponential model fitting curve"
      xLabel: ""
    ,
      name: 'LogNormal'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple LogNormal model fitting curve"
      xLabel: ""
    ,
      name: 'ChiSquared'
      value: 2
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class Designs a simple ChiSquared model fitting curve"
      xLabel: ""
    ,

      name: 'Geometric'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a Geometric distribution fitting curve to the dataset"
      xLabel: "Add x"
    ,

      name: 'Bernoulli'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a Bernoulli distribution fitting curve to the dataset"
      xLabel: "Add x"
    ,

      name: 'ContinuousUniform'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a Continuous Uniform distribution fitting curve to the dataset"
      xLabel: "Add x"
    ,

      name: 'DiscreteUniform'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a Discrete Uniform distribution fitting curve to the dataset"
      xLabel: "Add x"
    ,

      name: 'Poisson'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a Poisson distribution fitting curve to the dataset"
      xLabel: "Add x"
    ,

      name: 'Weibull'
      value: 0
      x: ['integer', 'number']
      y: false
      z: false
      message: "This class models a Weibull distribution fitting curve to the dataset"
      xLabel: "Add x"

    # ,
    #   name: 'Weibull'
    #   value: 2
    #   x: ['integer', 'number']
    #   y: false
    #   z: false
    #   message: "This class Designs a simple Weibull model fitting curve"
    #   xLabel: ""
    ]
