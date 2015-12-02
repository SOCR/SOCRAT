'use strict'

charts = angular.module('app_analysis_charts', [])

.factory('app_analysis_charts_constructor', [
  'app_analysis_charts_manager'
  (manager)->
    (sb)->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'charts init called'

      destroy: () ->

      msgList: _msgList
])

.factory( 'app_analysis_charts_manager', [
  ()->
    _sb = null

    _msgList =
      outgoing: ['get table']
      incoming: ['take table']
      scope: ['charts']

    _setSb = (sb) ->
      _sb = sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
])

.controller('mainchartsCtrl', [
  'app_analysis_charts_manager'
  '$scope'
  '$rootScope'
  'app_analysis_charts_dataTransform'
  (ctrlMngr,$scope) ->
    console.log 'mainchartsCtrl executed'
    _chart_data = null

    _updateData = () ->
      $scope.chartData = _chart_data

    $scope.tabs = []
    $scope.$on 'charts:graphDiv', (event, data) ->
      _chart_data = data
      console.log data
      $scope.tabs.push {
        name: _chart_data.name
        id: _chart_data.name.substr(0,2).toLowerCase()
      }
      console.log $scope.tabs
      _updateData()
])

.directive('myTabs', () ->
  return {
  replace: false,
  transclude: true,
  template: '<li><a data-toggle = "tab" href="{{t as t.name for t in tabs}}">{{t as t.name for t in tabs}}</a></li>'
  }
)
.directive('tabBody', () ->
  return {
  template: '<div id="{{t as t.name for t in tabs}}" class = "tab-pane fade" ><svg style="width:500px, height:500px"></svg></div>'
  }
)

.controller('sidechartsCtrl',[
  'app_analysis_charts_manager'
  '$scope'
  '$rootScope'
  '$stateParams'
  '$q'
  'app_analysis_charts_dataTransform'
  (ctrlMngr, $scope, $rootScope, $stateParams, $q, dataTransform) ->
    console.log 'sidechartsCtrl executed'
    _chartData = null
    #_graphInfo = null
    $scope.selector1={};
    $scope.selector2={};
    $scope.graphInfo = {graph:"", x:"", y:""}
    $scope.graphs = [{name:'Bar Graph', value:0},{name:'Scatter Plot', value:1},{name:'Histogram', value:2},{name:'Bubble Chart', value:3},{name:'Pie Chart', value:4}]
    $scope.graphSelect = {}

    $scope.change = (selector,headers, ind) ->
      for h in headers
        if selector.value is h.value then $scope.graphInfo[ind] = parseFloat h.key

    $scope.createGraph = (results) ->
      results = {
        xVar: _chartData[$scope.graphInfo.x]
        yVar: _chartData[$scope.graphInfo.y]
        name: $scope.graphInfo.graph
      }
      #_graphInfo = results
      #[_chartData[$scope.graphInfo.x], _chartData[$scope.graphInfo.y]]
      $rootScope.$broadcast 'charts:graphDiv', results

    $scope.change1 = ()->
      $scope.graphInfo.graph = $scope.graphSelect.name


    sb = ctrlMngr.getSb()

    # deferred = $q.defer()

    token = sb.subscribe
      msg:'take table'
      msgScope:['charts']
      listener: (msg, _data) ->
        $scope.headers = d3.entries _data.header
        _chartData = dataTransform.format(_data.data)

    sb.publish
      msg:'get table'
      msgScope:['charts']
      callback: -> sb.unsubscribe token
      data:
        tableName: $stateParams.projectId + ':' + $stateParams.forkId


])

.factory('app_analysis_charts_dataTransform',[
  () ->

    _transpose = (data) ->
      data[0].map (col, i) -> data.map (row) -> row[i]

    _transform = (data) ->
      for col in data
        obj = {}
        for value, i in col
          obj[i] = value
        d3.entries obj

    _format = (data) ->
      return _transform(_transpose(data))

    transform: _transform
    transpose:_transpose
    format: _format

])

.directive 'd3Charts', [
  () ->
    restrict: 'E'
    template: "<svg width='100%' height='600'></svg>"
    link: (scope, elem, attr) ->

      values = d3.range(1000).map(d3.random.bates(10))
      formatCount = d3.format(",.0f")
      margin = {top: 10, right: 30, bottom: 30, left: 30}
      width = 960 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      x = d3.scale.linear().domain([0,1]).range([0,width])

      data = d3.layout.histogram().bins(x.ticks(20))(values)

      yMax = d3.max data, (d) ->
        return d.y
      xAxis = d3.svg.axis().scale(x).orient("bottom")
      y = d3.scale.linear().domain([0,yMax]).range([height, 0])
      rawSvg = elem.find("svg")[0]
      svg = d3.select(rawSvg)
      _graph = svg.append('g').attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      _drawHist = (data) ->
        _graph.selectAll('.bar').remove()

        bar = _graph.selectAll('.bar').data(data).enter().append("g").attr("class", "bar").attr("transform",(d) => return "translate(" + x(d.x) + "," + y(d.y) + ")")
        bar.append('rect').attr('x', 1).attr('width', x(data[0].dx) - 1).attr 'height', (d) ->
          height - y(d.y)
        _graph.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call(xAxis)

      _drawHist data
      console.log data
      console.log values
]

.directive 'd3Charts1', [
  () ->
    restrict:'E'
    template:"<svg width='100%' height='600'></svg>"
    link: (scope, elem, attr) ->
      margin = {top: 10, right: 30, bottom: 30, left: 30}
      width = 960 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      x = null
      y = null
      xMax = null
      yMax = null
      xMin = null
      yMin = null
      xAxis = null
      yAxis = null
      svg = null
      data = null


      _drawHist = () ->
        values = d3.range(1000).map(d3.random.bates(10))
        console.log values
        arr = []
        for d in data.xVar
          arr.push parseFloat d.value
        console.log arr

        y = d3.scale.linear().domain([0,yMax]).range([height, 0])
        x = d3.scale.linear().domain([0,1]).range([0,width])
        yAxis = d3.svg.axis().scale(y).orient("left")
        xAxis = d3.svg.axis().scale(x).orient("bottom")

        dataHist = d3.layout.histogram().bins(x.ticks(5))(arr)
        console.log dataHist
        yMax = d3.max dataHist, (d) ->
          return d.y

        _graph = svg.append('g').attr("transform", "translate(" + margin.left + "," + margin.top + ")").attr("id", "remove")

        _graph.select('g').remove()
        bar = _graph.selectAll('.bar').data(dataHist).enter().append("g").attr("class", "bar").attr("transform",(d) => return "translate(" + x(d.x) + "," + y(d.y) + ")")
        bar.append('rect').style("fill", "steelblue").attr('x', 1).attr('width', x(dataHist[0].dx) - 1).attr 'height', (d) ->
          height - y(d.y)
        _graph.append("g").attr("class", "x axis").attr("stroke","#000").style("shape-rendering", "crispEdges").attr("transform", "translate(0," + height + ")").call(xAxis)


      _drawScatterplot = () ->

        scatterData = []
        i=1
        while i < data.xVar.length
          tmp = {}
          tmp = JSON.stringify({x: data.xVar[i].value , y:data.yVar[i].value})
          scatterData.push(JSON.parse(tmp))
          i++

        xMin = d3.min scatterData, (d) -> d.x
        yMin = d3.min scatterData, (d) -> d.y

        xMax = d3.max scatterData, (d) -> d.x
        yMax = d3.max scatterData, (d) -> d.y

        x = d3.scale.linear().domain([xMin,xMax]).range([ 0, width ])
        y = d3.scale.linear().domain([yMin,yMax]).range([ height, 0 ])
        xAxis = d3.svg.axis().scale(x).orient('bottom')
        yAxis = d3.svg.axis().scale(y).orient('left')

        _graphScatter = svg.append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")").attr("id", "remove")

        #scope.x = $rootScope.dataT2[xIndex]
        #scope.xLabel =scope.x[0].value
        #scope.y = $rootScope.dataT2[yIndex]
        #scope.yLabel = scope.y[0].value

        #scope.x1 = scope.chartData.xVar
        #scope.xLabel1 ="X"
        #scope.y1 = scope.chartData.yVar
        #scope.yLabel1 = "Y"

        #console.log xIndex
        #console.log yIndex
        #console.log $rootScope.dataT2

        #construct scope.data, will be used in svg.data()



        console.log scatterData
        x.domain([d3.min(scatterData, (d)->d.x), d3.max(scatterData, (d)->d.x)])
        y.domain([d3.min(scatterData, (d)->d.x), d3.max(scatterData, (d)->d.y)])

        # values
        xValue = (d)->d.x
        yValue = (d)->d.y

        # map dot coordination
        xMap = (d)-> x xValue(d)
        yMap = (d)-> y yValue(d)

        # set up fill color
        cValue = (d)-> d.y
        color = d3.scale.category10()

        # x axis
        _graphScatter.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call xAxis
        .append('text')
        .attr('class', 'label')
        .attr('x', width)
        .attr('y', -6)
        .style('text-anchor', 'end')
        #.text scope.xLabel1

        # y axis
        _graphScatter.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr('class', 'label')
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        #.text scope.yLabel1

        # add the tooltip area to the webpage
        tooltip = svg
        .append('div')
        .attr('class', 'tooltip')
        .style('opacity', 0)

        # draw dots
        _graphScatter.selectAll('.dot')
        .data(scatterData)
        .enter().append('circle')
        .attr('class', 'dot')
        .attr('r', 5)
        .attr('cx', xMap)
        .attr('cy', yMap)
        .style('fill', (d)->color cValue(d))
        .on('mouseover', (d)->
          tooltip.transition().duration(200).style('opacity', .9)
          tooltip.html('<br/>(' + xValue(d)+ ',' + yValue(d) + ')')
          .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
        .on('mouseout', (d)->
          tooltip. transition().duration(500).style('opacity', 0))

        # draw legend
        legend = _graphScatter.selectAll('.legend')
        .data(color.domain())
        .enter().append('g')
        .attr('class', 'legend')
        .attr('transform', (d, i)-> 'translate(0,' + i * 20 + ')')
        .text scope.yLabel1

        # draw legend colored rectangles
        legend.append('rect')
        .attr('x', width - 18)
        .attr('width', 18)
        .attr('height', 18)
        .style('fill', color)

        # draw legend text
        legend.append('text')
        .attr('x', width - 24)
        .attr('y', 9)
        .attr('dy', '.35em')
        .style('text-anchor', 'end')
        .text((d)-> d)

      scope.$watch 'chartData', (newChartData) ->
        if newChartData
          data = newChartData
          console.log data
          #id = '#'+ newInfo.name
          svg = d3.select(elem.find("svg")[0])
          svg.select("#remove").remove()
          if data.name is "Histogram"
            _drawHist()
          else if data.name is "Scatter Plot"
            _drawScatterplot()
]


.directive('scatterplot', [
  () ->
    restrict: 'EA'
    transclude: true
    template: "<div class='graph-container' height ='600' width = '100%'></div>"

    replace: true #replace the directive element with the output of the template.

# actual d3 graph
    link: (scope, element, attr)->
      margin ={top: 20, right: 50, bottom: 30, left: 50}
      width = 600 - margin.left - margin.right
      height = 300 - margin.top - margin.bottom

      # Listen to the changing in x, y variable
      scope.$watch 'chartData', (newChartData) ->
      #$rootScope.$on  'update X Y variable', (obj,xIndex, yIndex)->
        if newChartData
          d3.select(element[0]).selectAll('*').remove()
          x = d3.scale.linear().range([ 0, width ])
          y = d3.scale.linear().range([ height, 0 ])
          xAxis = d3.svg.axis().scale(x).orient('bottom')
          yAxis = d3.svg.axis().scale(y).orient('left')

          # Create SVG element
          svg = d3.select(element[0])
          .append("svg")
          .attr("width", width + margin.left + margin.right)
          .attr("height", height + margin.top + margin.bottom)
          .append("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          #scope.x = $rootScope.dataT2[xIndex]
          #scope.xLabel =scope.x[0].value
          #scope.y = $rootScope.dataT2[yIndex]
          #scope.yLabel = scope.y[0].value

          scope.x1 = scope.chartData.xVar
          scope.xLabel1 ="X"
          scope.y1 = scope.chartData.yVar
          scope.yLabel1 = "Y"

          #console.log xIndex
          #console.log yIndex
          #console.log $rootScope.dataT2

          #construct scope.data, will be used in svg.data()
          scope.data = []
          i=1
          while i < scope.x1.length
            tmp = {}
            tmp = JSON.stringify({x: scope.x1[i].value , y:scope.y1[i].value})
            scope.data.push(JSON.parse(tmp))
            i++


          console.log scope.data

          x.domain([d3.min(scope.data, (d)->d.x), d3.max(scope.data, (d)->d.x)])
          y.domain([d3.min(scope.data, (d)->d.x), d3.max(scope.data, (d)->d.y)])

          # values
          xValue = (d)->d.x
          yValue = (d)->d.y

          # map dot coordination
          xMap = (d)-> x xValue(d)
          yMap = (d)-> y yValue(d)

          # set up fill color
          cValue = (d)-> d.y
          color = d3.scale.category10()

          # x axis
          svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call xAxis
          .append('text')
          .attr('class', 'label')
          .attr('x', width)
          .attr('y', -6)
          .style('text-anchor', 'end')
          .text scope.xLabel1

          # y axis
          svg.append("g")
          .attr("class", "y axis")
          .call(yAxis)
          .append("text")
          .attr('class', 'label')
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text scope.yLabel1

          # add the tooltip area to the webpage
          tooltip = d3.select(element[0])
          .append('div')
          .attr('class', 'tooltip')
          .style('opacity', 0)

          # draw dots
          svg.selectAll('.dot')
          .data(scope.data)
          .enter().append('circle')
          .attr('class', 'dot')
          .attr('r', 5)
          .attr('cx', xMap)
          .attr('cy', yMap)
          .style('fill', (d)->color cValue(d))
          .on('mouseover', (d)->
            tooltip.transition().duration(200).style('opacity', .9)
            tooltip.html('<br/>(' + xValue(d)+ ',' + yValue(d) + ')')
            .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
          .on('mouseout', (d)->
            tooltip. transition().duration(500).style('opacity', 0))

          # draw legend
          legend = svg.selectAll('.legend')
          .data(color.domain())
          .enter().append('g')
          .attr('class', 'legend')
          .attr('transform', (d, i)-> 'translate(0,' + i * 20 + ')')
          .text scope.yLabel1

          # draw legend colored rectangles
          legend.append('rect')
          .attr('x', width - 18)
          .attr('width', 18)
          .attr('height', 18)
          .style('fill', color)

          # draw legend text
          legend.append('text')
          .attr('x', width - 24)
          .attr('y', 9)
          .attr('dy', '.35em')
          .style('text-anchor', 'end')
          .text((d)-> d)

      console.log 'scatter plot directive linked'
])
