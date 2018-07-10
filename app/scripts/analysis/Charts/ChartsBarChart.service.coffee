'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBarChart extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService',
    'app_analysis_charts_scatterPlot'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()
    @scatterPlot = @app_analysis_charts_scatterPlot

    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawBar: (data, labels, container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    for item in data
      item["x_vals"] = item["x"]
      item["y_vals"] = item["y"]

    if labels.xLab.value is "x"
      labels.xLab.value = "x_vals"

    if labels.yLab.value is "y"
      labels.yLab.value = "y_vals"

    # third variable true (grouping or stacked)
    if labels.zLab.value
#stacked bar chart true
      if flags.Stacked
#horizontal bar chart true
        if flags.Horizontal
          vlSpec = {
            "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
            "width": 500,
            "height": 500,
            "data": {"values": data},
            "layer": [{
              "selection": {
                "brush": {
                  "type": "interval",
                  "encodings": ["x"]
                }
              },
              "mark": "bar",
              "encoding": {
                "row": {
                  "field": labels.zLab.value,
                  "type": "ordinal",
                },
                "x": {
                  "field": labels.yLab.value,
                  "type": "quantitative",
                  "axis": {"title": labels.yLab.value}
                },
                "y": {
                  "aggregate": "mean",
                  "field": labels.xLab.value,
                  "type": "ordinal",
                  "axis": {"title": labels.xLab.value}
                },
                "color": {
                  "field": labels.zLab.value,
                  "type": "nominal",
                  "scale": {"scheme": "category20b"}
                },
                "opacity": {
                  "condition": {
                    "selection": "brush", "value": 1
                  },
                  "value": 0.7
                }
              }
            }, {
              "transform": [{
                "filter": {"selection": "brush"}
              }],
              "mark": "rule",
              "encoding": {
                "y": {
                  "aggregate": "mean",
                  "field": labels.yLab.value,
                  "type": "quantitative"
                },
                "color": {"value": "firebrick"},
                "size": {"value": 3}
              }
            }]
          }
#horizontal bar chart false - vertical
        else
          vlSpec = {
            "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
            "width": 500,
            "height": 500,
            "data": {"values": data},
            "layer": [{
              "selection": {
                "brush": {
                  "type": "interval",
                  "encodings": ["x"]
                }
              },
              "mark": "bar",
              "encoding": {
                "x": {
                  "field": labels.xLab.value,
                  "type": "ordinal",
                  "axis": {"title": labels.xLab.value}
                },
                "y": {
                  "aggregate": "mean",
                  "field": labels.yLab.value,
                  "type": "quantitative",
                  "axis": {"title": labels.yLab.value}
                },
                "color": {
                  "field": labels.zLab.value,
                  "type": "nominal",
                  "scale": {"scheme": "category20b"}
                },
                "opacity": {
                  "condition": {
                    "selection": "brush", "value": 1
                  },
                  "value": 0.7
                }
              }
            }, {
              "transform": [{
                "filter": {"selection": "brush"}
              }],
              "mark": "rule",
              "encoding": {
                "y": {
                  "aggregate": "mean",
                  "field": labels.yLab.value,
                  "type": "quantitative"
                },
                "color": {"value": "firebrick"},
                "size": {"value": 3}
              }
            }]
          }
#stacked bar chart false - double/.../n-le bar chart
      else
#horizontal bar chart true
        if flags.Horizontal
          vlSpec = {
            "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
            "width": 500,
            "height": 500,
            "data": {"values": data},
            "facet": {
              "row": {
                "field": labels.xLab.value,
                "type": "ordinal",
                "header": {
                  "title": labels.xLab.value
                }
              }
            },
            "spec": {
              "layer": [{
                "selection": {
                  "brush": {
                    "type": "interval",
                    "encodings": ["x"]
                  }
                },
                "mark": "bar",
                "encoding": {
                  "x": {
                    "aggregate": "mean",
                    "field": labels.yLab.value,
                    "type": "quantitative",
                    "axis": {"title": labels.yLab.value}
                  },
                  "y": {
                    "field": labels.zLab.value,
                    "type": "nominal",
                    "axis": {"title": ""}
                  },
                  "color": {
                    "field": labels.zLab.value,
                    "type": "nominal",
                    "legend": {
                      "title": labels.zLab.value
                    }
                    "scale": {"scheme": "category20b"}
                  },
                  "opacity": {
                    "condition": {
                      "selection": "brush", "value": 1
                    },
                    "value": 0.7
                  }
                }
              }, {
                "transform": [{
                  "filter": {"selection": "brush"}
                }],
                "mark": "rule",
                "encoding": {
                  "x": {
                    "aggregate": "mean",
                    "field": labels.yLab.value,
                    "type": "quantitative"
                  },
                  "color": {"value": "firebrick"},
                  "size": {"value": 3}
                }
              }]
            }
          }
#horizontal bar chart false - vertical
        else
          vlSpec = {
            "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
            "width": 500,
            "height": 500,
            "data": {"values": data},
            "facet": {
              "column": {
                "field": labels.xLab.value,
                "type": "ordinal",
                "header": {
                  "title": labels.xLab.value
                }
              }
            },
            "spec": {
              "layer": [{
                "selection": {
                  "brush": {
                    "type": "interval",
                    "encodings": ["x"]
                  }
                },
                "mark": "bar",
                "encoding": {
                  "x": {
                    "field": labels.zLab.value,
                    "type": "nominal",
                    "axis": {"title": ""}
                  },
                  "y": {
                    "aggregate": "mean",
                    "field": labels.yLab.value,
                    "type": "quantitative",
                    "axis": {"title": labels.yLab.value}
                  },
                  "color": {
                    "field": labels.zLab.value,
                    "type": "nominal",
                    "legend": {
                      "title": labels.zLab.value
                    }
                    "scale": {"scheme": "category20b"}
                  },
                  "opacity": {
                    "condition": {
                      "selection": "brush", "value": 1
                    },
                    "value": 0.7
                  }
                }
              }, {
                "transform": [{
                  "filter": {"selection": "brush"}
                }],
                "mark": "rule",
                "encoding": {
                  "y": {
                    "aggregate": "mean",
                    "field": labels.yLab.value,
                    "type": "quantitative"
                  },
                  "color": {"value": "firebrick"},
                  "size": {"value": 3}
                }
              }]
            }
          }
# third variable false (no grouping/stacked)
    else
# horizontal bar chart
      if flags.Horizontal
        vlSpec = {
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "width": 500,
          "height": 500,
          "data": {"values": data},
          "layer": [{
            "selection": {
              "brush": {
                "type": "interval",
                "encodings": ["x"]
              }
            },
            "mark": "bar",
            "encoding": {
              "y": {
                "field": labels.xLab.value,
                "type": "ordinal",
                "axis": {"title": labels.xLab.value}
              },
              "x": {
                "aggregate": "mean",
                "field": labels.yLab.value,
                "type": "quantitative",
                "axis": {"title": labels.yLab.value}
              },
              "opacity": {
                "condition": {
                  "selection": "brush", "value": 1
                },
                "value": 0.7
              }
            }
          }, {
            "transform": [{
              "filter": {"selection": "brush"}
            }],
            "mark": "rule",
            "encoding": {
              "x": {
                "aggregate": "mean",
                "field": labels.yLab.value,
                "type": "quantitative"
              },
              "color": {"value": "firebrick"},
              "size": {"value": 3}
            }
          }]
        }
# vertical bar chart
      else
        vlSpec = {
          "$schema": "https://vega.github.io/schema/vega-lite/v2.json",
          "width": 500,
          "height": 500,
          "data": {"values": data},
          "layer": [{
            "selection": {
              "brush": {
                "type": "interval",
                "encodings": ["x"]
              }
            },
            "mark": "bar",
            "encoding": {
              "x": {
                "field": labels.xLab.value,
                "type": "ordinal",
                "axis": {"title": labels.xLab.value}
              },
              "y": {
                "aggregate": "mean",
                "field": labels.yLab.value,
                "type": "quantitative",
                "axis": {"title": labels.yLab.value}
              },
              "opacity": {
                "condition": {
                  "selection": "brush", "value": 1
                },
                "value": 0.7
              }
            }
          }, {
            "transform": [{
              "filter": {"selection": "brush"}
            }],
            "mark": "rule",
            "encoding": {
              "y": {
                "aggregate": "mean",
                "field": labels.yLab.value,
                "type": "quantitative"
              },
              "color": {"value": "firebrick"},
              "size": {"value": 3}
            }
          }]
        }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      @vt.vegaLite(result.view, vlSpec)
    )
