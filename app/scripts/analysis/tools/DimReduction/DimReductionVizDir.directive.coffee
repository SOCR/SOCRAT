'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class DimReductionVizDir extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<div id='vis' class='graph-container' style='overflow:auto; height: 600px'></div>"
    # @template = "<svg width='100%' height='600'></svg>"
    @replace = true # replace the directive element with the output of the template

    @ve = require('vega-embed').default

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>

      scope.$watch 'mainArea.dataPoints', (newDataPoints) =>
        if newDataPoints
          drawDataPoints newDataPoints
      , on

      drawDataPoints = (dataPoints) =>

        fields = ['x t-SNE', 'y t-SNE']
        ordinal = dataPoints.header[2]

        d = []
        for row, row_ind in dataPoints.data
          row_obj = {}
          for label, lbl_idx in fields
            row_obj[label] = row[lbl_idx]
          if dataPoints.labels
            row_obj[ordinal] = dataPoints.labels[row_ind]
          d.push row_obj


        vlSpec =
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "width": 500,
          "height": 500,
          "data": {"values": d},
          "selection":
            "grid":
              "type": "interval", "bind": "scales"
          "mark": "circle",
          "encoding":
            "x":
              "field": "x t-SNE", "type": "quantitative", "axis": {"title": 'x t-SNE'}
            "y":
              "field": "y t-SNE", "type": "quantitative", "axis": {"title": 'y t-SNE'}

        if dataPoints.labels
          vlSpec['encoding']['color'] =
            "field": ordinal
            "type": "nominal"

        opt =
          "actions": {export: true, source: false, editor: false}

        @ve '#vis', vlSpec, opt, (error, result) ->
          # Callback receiving the View instance and parsed Vega spec
          # result.view is the View, which resides under the '#vis' element
          return
