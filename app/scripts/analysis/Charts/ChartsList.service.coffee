'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsList extends BaseService

  initialize: ->

  getFlat: () ->
    flat = [
      name: 'Scatter Plot Matrix'
      config:
        description: ""
        value: 0
        vars:
          placeholder: false
    ,
      name: 'Bar Graph'
      config:
        description: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
        value: 1
        vars:
          v: false
          w: false
          x: ['integer', 'number', 'string']
          y: ['integer', 'number', 'string']
          z: ['integer', 'string']
          xLabel: "X"
          yLabel: "Y"
          zLabel: "Color"
          threshold: ['integer', 'number', 'string']
          tLabel: "Threshold"
        params:
          horizontal: true
          stacked: true
          normalized: true
          x_residual: true
          y_residual: true
#          hLabel: "Toggle horizontal"
#          sLabel: "Toggle stacked"
#          nLabel: "Toggle normalized"
    ,
      name: 'Scatter Plot'
      config:
        description: "Choose an x variable and a y variable. If you'd like, also choose a z variable to denote color.",
        value: 2,
        vars:
          v: false
          w: false
          x: ['integer', 'number']
          y: ['integer', 'number']
          z: ['string']
          r: ['integer', 'string', 'number']
          xLabel: "X"
          yLabel: "Y"
          zLabel: "Color"
          rLabel: "Radius"
        params:
          binned: true
          showSTDEV: true
          opacity: true
          x_residual: true
          y_residual: true
#          bLabel: "Toggle binned"
#          sLabel: "Show statistics"
    ,
      name: 'Histogram'
      config:
        description: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
        value: 3
        vars:
          v: false
          w: false
          x: ['integer', 'number']
          y: ['integer', 'number']
          z: false
          xLabel: "X"
          yLabel: "Y"
        params:
          x_residual: true
          y_residual: true
    ,
      name: 'Tukey Box Plot (1.5 IQR)'
      config:
        description: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
        value: 4
        vars:
          v: false
          w: false
          x: ['integer', 'number', 'string']
          y: ['integer', 'number']
          z: false
          xLabel: "X"
          yLabel: "Y"
        params:
          y_residual: true
    ,
      name: 'Pie Chart'
      config:
        description: "Choose one variable to put into a pie chart."
        value: 6
        vars:
          v: false
          w: false
          x: ['integer', 'number', 'string']
          y: false
          z: false
          xLabel: "Category"
    ,
      name: 'Normal Distribution'
      config:
        description: "Choose one variable. This chart assumes there is a normal distribution."
        value: 7
        vars:
          v: false
          w: false
          x: ['integer', 'number']
          y: false
          z: false
          xLabel: "Category"
        params:
          x_residual: true
    ,
      name: 'Binned Heatmap'
      config:
        description: "Choose x, y, and z variables, along with max bin values."
        value: 8
        vars:
          v: false
          w: false
          x: ['integer', 'number', 'string']
          y: ['integer', 'number', 'string']
          z: ['integer', 'string']
          m: true
          xLabel: "X"
          yLabel: "Y"
          zLabel: "Z"
        params:
          xBin: true
          yBin: true
          marginalHist: true
          xbinLabel: "X Bin"
          ybinLabel: "Y Bin"
          x_residual: true
          y_residual: true
    ,
      name: 'Strip Plot'
      config:
        description: "Choose x and y variables."
        value: 9
        vars:
          v: false
          w: false
          x: ['integer', 'number']
          y: ['integer', 'number']
          z: false
          xLabel: "X"
          yLabel: "Y"
    ,
      name: 'Ranged Dot Plot'
      config:
        description: ""
        value: 10
        vars:
          v: false
          w: false
          x: ['integer', 'number', 'string']
          y: ['integer', 'number', 'string']
          z: ['string']
          r: false
          xLabel: "X"
          yLabel: "Y"
          zLabel: "Color"
        params:
          x_residual: true
    ,
      name: 'Word Cloud'
      config:
        description: ""
        value: 11
        vars:
          v: false
          w: false
          x: false
          y: false
          z: false
          r: false
          startAngle: ['integer', 'number']
          endAngle: ['integer', 'number']
          orientations: ['integer', 'number']
          text: ['string']
          startLabel: "Start Angle"
          endLabel: "End Angle"
          orientationsLabel: "Number of Orientations"
          textLabel: "Input String"
    ,
      name: 'Cumulative Frequency'
      config:
        description: ""
        value: 12
        vars:
          v: false
          w: false
          x: ['integer', 'number', 'string']
          y: false
          z: false
          r: false
        params:
          x_residual: true
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
      name: 'Area Chart'
      config:
        description: "Pick date variable for x and numerical variable for y"
        value: 9
        vars:
          v: false
          w: false
          x: ['date']
          y: ['integer', 'number']
          z: false
          xLabel: "X (date)"
          yLabel: "Y"
    ,
      name: 'Line Chart'
      value: 10
      x: ['date']
      y: ['integer', 'number']
      z: ['string']
      message: "Choose a continuous variable for x and a numerical variable for y"
      xLabel: "X (date)"
      yLabel: "Y"
      zLabel: "Category (if applicable)"
    ,
      name: 'Stream Graph'
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
      name: 'Area Trellis Chart'
      value: 12
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
      name: 'Sunburst'
      value: 20
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: ['string']
      r: ['string']
      message: ""
      xLabel: "Key"
      yLabel: "Parent"
      zLabel: "Name"
      rLabel: "Size"
    ,
      name: 'Bullet Chart'
      value: 18
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: false
      r: ['string']
      message: ""
      xLabel: "X"
      yLabel: "Y"
      rLabel: "Row"
    ,
      name: 'Diverging Stacked Bar Chart'
      value: 16
      v: false
      w: false
      x: ['integer', 'number', 'string']
      y: ['integer', 'number', 'string']
      z: ['string']
      r: ['integer', 'number']
      message: ""
      xLabel: "Percentage Start"
      yLabel: "Y"
      zLabel: "Color"
      rLabel: "Percentage End"
    ]
