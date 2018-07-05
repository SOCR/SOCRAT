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
      z: ['integer', 'string']
      h: true
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "X"
      yLabel: "Y"
      zLabel: "Color"
      hLabel: "Toggle horizontal"
    ,
      name: 'Scatter Plot'
      value: 2
      v: false
      w: false
      x: ['integer', 'number']
      y: ['integer', 'number']
      z: ['string']
      message: "Choose an x variable and a y variable. If you'd like, also choose a z variable to denote color."
      xLabel: "X"
      yLabel: "Y"
    ,
      name: 'Histogram'
      value: 3
      v: false
      w: false
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: "X"
    ,
      name: 'Tukey Box Plot (1.5 IQR)'
      value: 4
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: ['integer', 'number']
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: "X"
      yLabel: "Y"
    ,
      name: 'Bubble Chart'
      value: 5
      v: false
      w: false
      x: ['integer', 'number']
      y: ['integer', 'number']
      z: ['integer', 'string']
      r: ['integer', 'number']
      message: "Choose an x variable, a y variable and a radius variable."
      xLabel: "X"
      yLabel: "Y"
      zLabel: "Color"
      rLabel: "Radius"
    ,
      name: 'Pie Chart'
      value: 6
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: "Category"
    ,
      name: 'Normal Distribution'
      value: 7
      v: false
      w: false
      x: ['integer', 'number']
      y: false
      z: false
      message: "Choose one variable. This chart assumes there is a normal distribution."
      xLabel: "Category"
    ,
      name: 'Ring Chart'
      value: 8
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: "Category"
    ,
      name: 'Line Chart'
      value: 9
      v: false
      w: false
      x: ['date']
      y: ['integer', 'number']
      z: ['string']
      message: "Choose a continuous variable for x and a numerical variable for y"
      xLabel: "X (date)"
      yLabel: "Y"
      zLabel: "Category (if applicable)"
    ,
      name: 'Stream Graph'
      value: 10
      v: false
      w: false
      x: ['date']
      y: ['integer', 'number']
      z: ['string']
      message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
      xLabel: "X (date)"
      yLabel: "Y"
      zLabel: "Key"
    ,
      name: 'Area Trellis Chart'
      value: 11
      v: false
      w: false
      x: ['date']
      y: ['integer', 'number']
      z: ['string']
      message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
      xLabel: "X (date)"
      yLabel: "Y"
      zLabel: "Key"
    ,
      name: 'Binned Heatmap'
      value: 12
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: ['integer', 'string']
      xbin: ['integer']
      ybin: ['integer']
      message: "Choose x, y, and z variables, along with max bin values."
      xLabel: "X"
      yLabel: "Y"
      zLabel: "Z"
      xbinLabel: "X Bin"
      ybinLabel: "Y Bin"
    ,
      name: 'Strip Plot'
      value: 13
      v: false
      w: false
      x: ['integer', 'number']
      y: ['integer', 'number']
      z: false
      message: "Choose x and y variables."
      xLabel: "X"
      yLabel: "Y"

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
      xLabel: "X (date)"
      yLabel: "Y"
      zLabel: "Key"
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
      xLabel: "X (date)"
      yLabel: "Y"
    ,
      name: 'Stream Graph'
      value: 13
      v: false
      w: false
      x: true
      y: true
      z: true
      message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
      xLabel: "X (date)"
      yLabel: "Y"
      zLabel: "Z"
    ,
      name: 'Trellis Chart'
      value: 0
      v: false
      w: false
      x: true
      y: true
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
      xLabel: "X"
      yLabel: "Y"
      zLabel: "Color"
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
      xLabel: "X"
      yLabel: "Y"
    ,
      name: 'Histogram'
      value: 3
      v: false
      w: false
      x: true
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
      xLabel: "X"
    ,
      name: 'Bubble Chart'
      value: 4
      v: false
      w: false
      x: true
      y: true
      z: true
      message: "Choose an x variable, a y variable and a radius variable."
      xLabel: "X"
      yLabel: "Y"
      zLabel: "Color"
      rLabel: "Radius"
    ,
      name: 'Pie Chart'
      value: 5
      v: false
      w: false
      x: true
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
      xLabel: "Category"
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
      xLabel: "Category"
    ]
