'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTrellisChart extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService',
    'app_analysis_charts_scatterPlot'
  # @inject 'app_analysis_cluster_dataService'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()
    @scatterPlot = @app_analysis_charts_scatterPlot

  '''
  parseData: (data) ->
    @dataService.inferDataTypes data, (resp) =>
      if resp and resp.dataFrame and resp.dataFrame.data
        @dataFrame = resp.dataFrame
        @updateSidebarControls()
        @updateDataPoints()
  '''
  drawTrellis: (width,height,data,_graph,gdata,container) ->

    dataFr = {}

    data = @dataService.getData().then (obj) =>
      if obj.dataFrame and obj.dataFrame.dataType?
        dataFrame = obj.dataFrame

        fields = []
        all_fields = []
        all_field_indices = []
        ordinals = []
        ordinal_indices = []
        field_indices = []
        ordinal = ""
        ordinalTitle = ""
        k = 0
        ordinal_index = 0
        mark = "point"

        '''
        @check_mark() =>
          if a.data == b.data
            return bar
          else
            return "point"
        '''

        for i in dataFrame.header
          try
            if (!isNaN(parseInt(dataFrame.data[0][k])) && fields.length < 4)
              fields.push(i)
              field_indices.push(k)
              all_fields.push(i)
              all_field_indices.push(k)
            else if (!isNaN(parseInt(dataFrame.data[0][k])))
              all_fields.push(i)
              all_field_indices.push(k)
            else
              ordinal_indices.push(k)
              ordinals.push(i)
              ordinal = i
              ordinalTitle = i
              ordinal_index = k
          catch error
            console.log(error)
          k++

        console.log('whattaup')
        console.log(gdata.xLab.value)
        fields[2] = gdata.xLab.value
        console.log(gdata.yLab.value)
        fields[3] = gdata.yLab.value
        console.log(gdata.zLab.value)
        ordinal = gdata.zLab.value
        ordinalTitle = gdata.zLab.value

        ind = 0
        for x in dataFrame.header
          if ordinal == x
            ordinal_index = ind
          ind += 1

        ind = 0
        for x in dataFrame.header
          if fields[2] == x
            field_indices[2] = ind
          if fields[3] == x
            field_indices[3] = ind
          ind += 1

        console.log('indiceessss')
        console.log(ordinal_index)
        console.log(field_indices)


        # fields = dataFrame.header.slice(0, 0 + 4)
        # ordinal = dataFrame.header[4]
        # ordinalTitle = dataFrame.header[4]
        console.log('theeeeesseee things')
        console.log(fields)
        console.log(ordinal)
        console.log(ordinalTitle)
        console.log('ordinals')
        console.log(ordinals)
        console.log('all fields')
        console.log(all_fields)

        k = 0
        y = 0
        d = []
        for i in dataFrame.data
          d[k] = {}
          y = 0
          for j in fields
            dataFrame.data[k][j] = parseFloat(dataFrame.data[k][field_indices[y]])
            d[k][j] = parseFloat(dataFrame.data[k][field_indices[y]])
            y++
          dataFrame.data[k][ordinal] = dataFrame.data[k][ordinal_index]
          d[k][ordinal] = dataFrame.data[k][ordinal_index]
          k++

        console.log(d)
        console.log(x)
        console.log(fields.length)
        console.log(fields)

        unique_fields = []

        for x in fields
          if x not in unique_fields
            unique_fields.push(x)

        vSpec = {
          "width": 180 * unique_fields.length,
          "height": 180 * unique_fields.length,
          "data": [
            {
              "name": "iris",
              "values": d
            },
            {
              "name": "fields",
              "values": fields
            }
          ],
          "signals": [
            {
              "name": "cell",
              "init": {},
              "streams": [
                {"type": "@cell:mousedown, @point:mousedown", "expr": "eventGroup()"}
              ]
            },
            {
              "name": "start_coords",
              "init": {},
              "streams": [{
                "type": "@cell:mousedown, @point:mousedown",
                "expr": "{x: clamp(eventX(cell), 0, cell.width), y: clamp(eventY(cell), 0, cell.height)}"
              }]
            },
            {
              "name": "end_coords",
              "init": {},
              "streams": [{
                "type": "@cell:mousedown, @point:mousedown, [(@cell:mousedown, @point:mousedown), window:mouseup] > window:mousemove",
                "expr": "{x: clamp(eventX(cell), 0, cell.width), y: clamp(eventY(cell), 0, cell.height)}"
              }]
            },
            {
              "name": "start_data",
              "init": {},
              "expr": "{x: iscale('x', start_coords.x, cell), y: iscale('y', start_coords.y, cell)}"
            },
            {
              "name": "end_data",
              "init": {},
              "expr": "{x: iscale('x', end_coords.x, cell), y: iscale('y', end_coords.y, cell)}"
            },
            {
              "name": "brush",
              "init": {"x1": 0, "y1": 0, "x2": 0, "y2": 0},
              "streams": [{
                "type": "start_coords, end_coords",
                "expr": "{x1: cell.x + start_coords.x, y1: cell.y + start_coords.y, x2: cell.x + end_coords.x, y2: cell.y + end_coords.y}"
              }]
            }
          ],
          "scales": [
            {
              "name": "gx",
              "type": "ordinal",
              "range": "width",
              "round": true,
              "domain": {"data": "fields", "field": "data"}
            },
            {
              "name": "gy",
              "type": "ordinal",
              "range": "height",
              "round": true,
              "reverse": true,
              "domain": {"data": "fields", "field": "data"}
            },
            {
              "name": "c",
              "type": "ordinal",
              "domain": {
                "data": "iris",
                "field": ordinal
              },
              "range": "category10"
            }
          ],
          "legends": [
            {
              "fill": "c",
              "title": ordinal,
              "offset": 10,
              "properties": {
                "symbols": {
                  "fillOpacity": {"value": 0.5},
                  "stroke": {"value": "transparent"}
                }
              }
            }
          ],
          "marks": [
            {
              "name": "cell",
              "type": "group",
              "from": {
                "data": "fields",
                "transform": [{"type": "cross"}]
              },
              "properties": {
                "enter": {
                  "a": {"field": "a.data"},
                  "b": {"field": "b.data"},
                  "x": {"scale": "gx", "field": "a.data"},
                  "y": {"scale": "gy", "field": "b.data"},
                  "width": {"scale": "gx", "band": true, "offset":-35},
                  "height": {"scale": "gy", "band": true, "offset":-35},
                  "fill": {"value": "#fff"},
                  "stroke": {"value": "#ddd"}
                }
              },
              "scales": [
                {
                  "name": "x",
                  "type": "linear",
                  "domain": {"data": "iris", "field": {"parent": "a.data"}},
                  "range": "width",
                  "zero": false,
                  "round": true
                },
                {
                  "name": "y",
                  "type": "linear",
                  "domain": {"data": "iris", "field": {"parent": "b.data"}},
                  "range": "height",
                  "zero": false,
                  "round": true
                }
              ],
              "axes": [
                {
                  "type": "x",
                  "scale": "x",
                  "ticks": 5,
                  "labels": {
                    "interactive": true,
                  }
                },
                {"type": "y", "scale": "y", "ticks": 5}
              ],
              "marks": [
                {
                  "name": mark,
                  "type": "symbol",
                  "from": {"data": "iris"},
                  "properties": {
                    "enter": {
                      "x": {"scale": "x", "field": {"datum": {"parent": "a.data"}}},
                      "y": {"scale": "y", "field": {"datum": {"parent": "b.data"}}},
                      "fill": {"scale": "c", "field": ordinal},
                      "fillOpacity": {"value": 0.5},
                      "size": {"value": 36}
                    },
                    "update": {
                      "fill": [
                        {
                          "test": "inrange(datum[cell.a], start_data.x, end_data.x) && inrange(datum[cell.b], start_data.y, end_data.y)",
                          "scale": "c",
                          "field": ordinal
                        },
                        {"value": "grey"}
                      ]
                    }
                  }
                }
              ]
            },

            {
              "type": "rect",
              "properties": {
                "enter": {
                  "fill": {"value": "grey"},
                  "fillOpacity": {"value": 0.2}
                },
                "update": {
                  "x":  {"signal": "brush.x1"},
                  "y":  {"signal": "brush.y1"},
                  "x2": {"signal": "brush.x2"},
                  "y2": {"signal": "brush.y2"}
                }
              }
            }
          ]
        }

        vg.embed '#vis', vSpec, (error, result) ->
          # Callback receiving the View instance and parsed Vega spec
          # result.view is the View, which resides under the '#vis' element
          return

        console.log('zipzipzizpzip')
        console.log(dataFrame)
        dataFr = dataFrame
        return dataFrame
        switch dataFrame.dataType
          when @DATA_TYPES.FLAT
            @dataType = @DATA_TYPES.FLAT
  #          @parseData dataFrame
  #            @chartData = @dataTransform.format dataFrame.data
          when @DATA_TYPES.NESTED
            @graphs = @list.getNested()
            @data = dataFrame.data
            @dataType = @DATA_TYPES.NESTED
            @header = {key: 0, value: "initiate"}
    return
