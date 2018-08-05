'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBulletChart extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()

    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawBulletChart: (data, labels, container) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    console.log(data)

#    vlSpec = {
#      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
#      "width": 500,
#      "height": 500,
#      "data": {
#        "values": [
#          {"title":"Revenue","subtitle":"US$, in thousands","ranges":[150,225,300],"measures":[220,270],"markers":[250]},
#          {"title":"Profit","subtitle":"%","ranges":[20,25,30],"measures":[21,23],"markers":[26]},
#          {"title":"Order Size","subtitle":"US$, average","ranges":[350,500,600],"measures":[100,320],"markers":[550]},
#          {"title":"New Customers","subtitle":"count","ranges":[1400,2000,2500],"measures":[1000,1650],"markers":[2100]},
#          {"title":"Satisfaction","subtitle":"out of 5","ranges":[3.5,4.25,5],"measures":[3.2,4.7],"markers":[4.4]}
#        ]
#      },
#      "facet": {
#        "row": {
#          "field": "title", "type": "ordinal",
#          "header": {"labelAngle": 0, "title": ""}
#        }
#      },
#      "spec": {
#        "layer": [{
#          "mark": {"type": "bar", "color": "#eee"},
#          "encoding": {
#            "x": {
#              "field": "ranges[2]", "type": "quantitative", "scale": {"nice": false},
#              "title": null
#            }
#          }
#        },{
#          "mark": {"type": "bar", "color": "#ddd"},
#          "encoding": {
#            "x": {"field": "ranges[1]", "type": "quantitative"}
#          }
#        },{
#          "mark": {"type": "bar", "color": "#ccc"},
#          "encoding": {
#            "x": {"field": "ranges[0]", "type": "quantitative"}
#          }
#        },{
#          "mark": {"type": "bar", "color": "lightsteelblue", "size": 10},
#          "encoding": {
#            "x": {"field": "measures[1]", "type": "quantitative"}
#          }
#        },{
#          "mark": {"type": "bar", "color": "steelblue", "size": 10},
#          "encoding": {
#            "x": {"field": "measures[0]", "type": "quantitative"}
#          }
#        },{
#          "mark": {"type": "tick", "color": "black"},
#          "encoding": {
#            "x": {"field": "markers[0]", "type": "quantitative"}
#          }
#        }]
#      },
#      "resolve": {
#        "scale": {
#          "x": "independent"
#        }
#      },
#      "config": {
#        "tick": {"thickness": 2}
#      }
#    }

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
      "width": 500,
      "height": 500,
      "data": {"values": data},
      "facet": {
        "row": {
          "field": labels.rLab.value, "type": "ordinal",
          "header": {"labelAngle": 0, "title": ""}
        }
      },
      "spec": {
        "layer": [{
          "mark": {"type": "bar", "color": "steelblue"},
          "encoding": {
            "x": {"field": labels.xLab.value, "type": "quantitative"}
          }
        }, {
          "mark": {"type": "bar", "color": "black"},
          "encoding": {
            "x": {"field": labels.yLab.value, "type": "quantitative"}
          }
        }]
      },
      "resolve": {
        "scale": {
          "x": "independent"
        }
      },
      "config": {
        "tick": {"thickness": 2}
      }
    }

#    result = data.map((a) ->
#      a[labels.xLab.value]
#    )
#
#    for item in result
#      mark = {
#          "mark": {"type": "bar", "color": "black"},
#          "encoding": {
#            "x": {"field": item, "type": "quantitative"}
#          }
#        }
#      vlSpec["spec"]["layer"].push(mark)
#
#    result = data.map((a) ->
#      a[labels.yLab.value]
#    )
#
#    for item in result
#      mark = {
#        "mark": {"type": "bar", "color": "steelblue"},
#        "encoding": {
#          "x": {"field": item, "type": "quantitative"}
#        }
#      }
#      vlSpec["spec"]["layer"].push(mark)

    opt =
      "actions": {export: true, source: false, editor: true}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
