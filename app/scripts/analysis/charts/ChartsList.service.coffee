'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Trellis Chart'
      value: 0
    ,
      name: 'Bar Graph'
      value: 1
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Scatter Plot'
      value: 2
      v: false
      w: false
      x: ['integer', 'number']
      y: ['integer', 'number']
      z: false
      message: "Choose an x variable and a y variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Histogram'
      value: 3
      v: false
      w: false
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: ""
    ,
      name: 'Bubble Chart'
      value: 4
      v: false
      w: false
      x: ['integer', 'number']
      y: ['integer', 'number']
      z: ['integer', 'number']
      message: "Choose an x variable, a y variable and a radius variable."
      xLabel: "Add x"
      yLabel: "Add y"
      zLabel: "Add radius"
    ,
      name: 'Pie Chart'
      value: 5
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: ""
    ,
      name: 'Normal Distribution'
      value: 6
      v: false
      w: false
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose one variable. This chart assumes there is a normal distribution."
      xLabel: ""
    ,
      name: 'Ring Chart'
      value: 7
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: ""

    ]

  getNested: () ->
    nested = [
      name: 'Stream Graph'
      value: 8
      v: false
      w: false
      x: true
      y: true
      z: true
      message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
      xLabel: "Add x (date)"
      yLabel: "Add y"
      zLabel: "Add key"
    ,
      name: 'Treemap'
      value: 9
      v: false
      w: false
      x: false
      y: false
      z: false
      message: ""
    ]

  getTime: () ->
    time = [
      name: 'Area Chart'
      value: 10
      v: false
      w: false
      x: true
      y: true
      z: false
      message: "Pick date variable for x and numerical variable for y"
      xLabel: "Add x (date)"
      yLabel: "Add y"
    ,
      name: 'Line Chart'
      value: 11
      v: false
      w: false
      x: true
      y: true
      z: false
      message: "Choose a continuous variable for x and a numerical variable for y"
      xLabel: "Add x (date)"
      yLabel: "Add y"
    ,
      name: 'Bivariate Area Chart'
      value: 12
      v: false
      w: false
      x: true
      y: true
      z: true
      message: "Choose a date variable for x and two numerical variables for y and z"
      xLabel: "Add x (date)"
      yLabel: "Add y"
      zLabel: "Add z"
    ,
      name: 'Stream Graph'
      value: 13
      v: false
      w: false
      x: true
      y: true
      z: true
      message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
      xLabel: "Add x (date)"
      yLabel: "Add y"
      zLabel: "Add key"
    ,
      name: 'Trellis Chart'
      value: 0
      v: false
      w: false
      x: true
      y: true
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Bar Graph'
      value: 1
      v: false
      w: false
      x: true
      y: true
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Scatter Plot'
      value: 2
      v: false
      w: false
      x: true
      y: true
      z: false
      message: "Choose an x variable and a y variable."
      xLabel: "Add x"
      yLabel: "Add y"
    ,
      name: 'Histogram'
      value: 3
      v: false
      w: false
      x: true
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: ""
    ,
      name: 'Bubble Chart'
      value: 4
      v: false
      w: false
      x: true
      y: true
      z: true
      message: "Choose an x variable, a y variable and a radius variable."
      xLabel: "Add x"
      yLabel: "Add y"
      zLabel: "Add radius"
    ,
      name: 'Pie Chart'
      value: 5
      v: false
      w: false
      x: true
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: ""
    ,
      name: 'Normal Distribution'
      value: 6
      v: false
      w: false
      x: true
      y: false
      z: false
      message: "Choose one variable."
      xLabel: ""
    ,
      name: 'Ring Chart'
      value: 7
      v: false
      w: false
      x: true
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: ""
    ]



