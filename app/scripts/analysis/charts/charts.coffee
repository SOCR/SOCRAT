'use strict'

charts = angular.module('app_analysis_charts', [])

.factory('app_analysis_charts_constructor', [
  'app_analysis_charts_manager'
  (manager)->
    (sb)->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log '%cCHARTS: charts init called'

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

.controller('mainChartsCtrl', [
  'app_analysis_charts_manager'
  '$scope'
  (ctrlMngr,$scope) ->
    _chart_data = null

    _updateData = () ->
      $scope.chartData = _chart_data

    $scope.$on 'charts:graphDiv', (event, data) ->
      _chart_data = data
      _updateData()
])



.controller('sideChartsCtrl',[
  'app_analysis_charts_manager'
  '$scope'
  '$rootScope'
  '$stateParams'
  '$q'
  'app_analysis_charts_dataTransform'
  (ctrlMngr, $scope, $rootScope, $stateParams, $q, dataTransform) ->
    _chartData = null
    _headers = null

    $scope.selector1 = {}
    $scope.selector2 = {}
    $scope.selector3 = {}

    $scope.graphInfo =
      graph: ""
      x: ""
      y: ""
      z: ""

    $scope.graphs = [
      name: 'Bar Graph'
      value: 0
    ,
      name: 'Scatter Plot'
      value: 1
    ,
      name: 'Histogram'
      value: 2
    ,
      name: 'Bubble Chart'
      value: 3
    ,
      name: 'Pie Chart'
      value: 4
    ]
    $scope.graphSelect = {}



    $scope.createGraph = () ->
      graphFormat = () ->
        obj = []
        len = _chartData[0].length

        if $scope.graphInfo.y is "" and $scope.graphInfo.z is ""
          obj = []

          for i in [1...len] by 1
            tmp =
              x: parseFloat _chartData[$scope.graphInfo.x][i].value
            obj.push tmp

        else if $scope.graphInfo.y isnt "" and $scope.graphInfo.z is ""
          obj = []

          for i in [1...len] by 1
            tmp =
              x: parseFloat _chartData[$scope.graphInfo.x][i].value
              y: parseFloat _chartData[$scope.graphInfo.y][i].value
            obj.push tmp

        else
          obj = []

          for i in [1...len] by 1
            tmp =
              x: parseFloat _chartData[$scope.graphInfo.x][i].value
              y: parseFloat _chartData[$scope.graphInfo.y][i].value
              z: parseFloat _chartData[$scope.graphInfo.z][i].value
            obj.push tmp

        return obj
      send = graphFormat()
      results =
        data: send
        xLab: _headers[$scope.graphInfo.x],
        yLab: _headers[$scope.graphInfo.y],
        zLab: _headers[$scope.graphInfo.z],
        name: $scope.graphInfo.graph

      $rootScope.$broadcast 'charts:graphDiv', results

    $scope.changeName = () ->
      $scope.graphInfo.graph = $scope.graphSelect.name
      $scope.createGraph()

    $scope.changeVar = (selector,headers, ind) ->
      for h in headers
        if selector.value is h.value then $scope.graphInfo[ind] = parseFloat h.key
      $scope.createGraph()

    sb = ctrlMngr.getSb()

    token = sb.subscribe
      msg:'take table'
      msgScope:['charts']
      listener: (msg, _data) ->
        _headers = d3.entries _data.header
        $scope.headers = _headers
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

.factory 'scatterplot', [
  () ->
    _drawScatterplot = (data,ranges,width,height,_graph,container,gdata) ->

      x = d3.scale.linear().domain([ranges.xMin,ranges.xMax]).range([ 0, width ])
      y = d3.scale.linear().domain([ranges.yMin,ranges.yMax]).range([ height, 0 ])
      xAxis = d3.svg.axis().scale(x).orient('bottom')
      yAxis = d3.svg.axis().scale(y).orient('left')

      # values
      xValue = (d)->parseFloat d.x
      yValue = (d)->parseFloat d.y

      # map dot coordination
      xMap = (d)-> x xValue(d)
      yMap = (d)-> y yValue(d)

      # set up fill color
      cValue = (d)-> d.y
      color = d3.scale.category10()

      # x axis
      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call xAxis
      .append('text')
      .attr('class', 'label')
      .attr('x', width)
      .attr('y', -6)
#          .style('text-anchor', 'end')
      .text gdata.xLab.value

      # y axis
      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr('class', 'label')
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
#          .style("text-anchor", "end")
      .text gdata.yLab.value

      # add the tooltip area to the webpage
      tooltip = container
      .append('div')
      .attr('class', 'tooltip')
      #          .style('opacity', 0)

      # draw dots
      _graph.selectAll('.dot')
      .data(data)
      .enter().append('circle')
      .attr('class', 'dot')
      .attr('r', 5)
      .attr('cx', xMap)
      .attr('cy', yMap)
      .style('fill', (d)->color cValue(d))
      .on('mouseover', (d)->
        tooltip.transition().duration(200).style('opacity', .9)
        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">(' + xValue(d)+ ',' + yValue(d) + ')</div>')
        .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
      .on('mouseout', (d)->
        tooltip. transition().duration(500).style('opacity', 0))



    drawScatterplot: _drawScatterplot

]

.factory 'histogram',[
  () ->
    _drawHist = (_graph,data,container,gdata,width,height) ->
      container.append('input').attr('id', 'slider').attr('type','range').attr('min', '1').attr('max','10').attr('step', '1').attr('value','5')
      bins = null
      dataHist = null

      arr = data.map (d) -> parseFloat d.x
      x = d3.scale.linear().domain([0,d3.max arr]).range([0,width])


      plotHist = (bins) ->
        dataHist = d3.layout.histogram().bins(bins)(arr)

        y = d3.scale.linear().domain([0, d3.max dataHist.map (i) -> i.length]).range([0, height])

        yAxis = d3.svg.axis().scale(y).orient("left")
        xAxis = d3.svg.axis().scale(x).orient("bottom")

        _graph.selectAll('g').remove()
        _graph.select('.x axis').remove()
        _graph.select('.y axis').remove()

        # x axis
        _graph.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call xAxis
        .append('text')
        .attr('class', 'label')
        .attr('x', width)
        .attr('y', -6)
    #            .style('text-anchor', 'end')
        .text gdata.xLab.value

        # y axis
        _graph.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr('class', 'label')
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
    #            .style("text-anchor", "end")
        .text "Count"

        bar = _graph.selectAll('.bar')
        .data(dataHist)

        bar.enter()
        .append("g")

        bar.append('rect')
    #            .style('fill', 'steelblue')
        .attr('x', (d,i) -> i*5 + x d.x)
        .attr('y', (d) -> height - y d.y)
        .attr('width', (d) -> x d.dx)
        .attr('height', (d) -> y d.y)
        .on('mouseover', () -> d3.select(this).transition().style('fill', 'orange'))
        .on('mouseout', () -> d3.select(this).transition().style('fill', 'steelblue'))

        bar.append('text')
        .attr('x', (d,i) -> i*5 + x d.x)
        .attr('y', (d) -> height - y d.y)
        .attr('dx', (d) -> .5*x d.dx)
        .attr('dy', '20px')
        .attr('fill', '#fff')
        .attr('text-anchor', 'middle')
        .attr('z-index', 1)
        .text (d) -> d.y

      plotHist(5) #pre-set value of slider

      d3.select('#slider')
      .on('change', () ->
        bins = parseInt this.value
        plotHist(bins)
      )
    drawHist: _drawHist
]

.factory 'pie', [
  () ->
    pieData = null
    makePieData = (data) ->
      pieMax = d3.max(data, (d)->parseFloat d.x)
      pieMin = d3.min(data, (d)->parseFloat d.x)
      maxPiePieces = 7  # set magic constant to variable
      rangeInt = Math.ceil((pieMax - pieMin)/maxPiePieces)
      piePieces = new Array(maxPiePieces - 1)  # create array with numbers of pie pieces
      for i in [0..maxPiePieces-1] by 1
        piePieces[i] = []

      for el in data
        index = Math.floor((el.x - pieMin)/rangeInt)
        piePieces[index].push(el.x) # assign each el.x to a piePiece
        console.log "piePieces[" + index + "]=" + piePieces[index]

      obj = {}
      for i in [0..maxPiePieces-1] by 1
        obj[i] = piePieces[i].length

      pieData = d3.entries obj
      return pieData

    _drawPie = (data,width,height,_graph) ->
      makePieData(data)
      radius = Math.min(width, height) / 2

      arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(0)

      labelArc = d3.svg.arc()
      .outerRadius(radius-10)
      .innerRadius(radius-10)

      color = d3.scale.ordinal().range(["#ffffcc","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#0c2c84"])

      arcOver = d3.svg.arc()
      .outerRadius(radius + 10)
      #                    .innerRadius(0+10)

      pie = d3.layout.pie()
      #.value (d) -> d.count
      .value (d) -> parseFloat d.value
      type = (d) ->
        d.y = +d.y
        return d

      arcs = _graph.selectAll(".arc")
      .data(pie(pieData))
      .enter()
      .append('g')
      .attr("class", "arc")

      arcs.append('path')
      .attr('d', arc)
      .attr('fill', (d) -> color(d.data.key))
      .on('mouseenter', (d) -> d3.select(this).attr("stroke","white").transition().attr("d", arcOver).attr("stroke-width",5))
      .on('mouseleave', (d) -> d3.select(this).transition().attr('d', arc).attr("stroke", "none"))

      arcs.append('text')
      .attr('id','tooltip')
      .attr('transform', (d) -> 'translate('+arc.centroid(d)+')')
      .attr('text-anchor', 'middle')
      .text (d) -> d.data.key
    drawPie: _drawPie
]

.factory 'bubble', [
  () ->
    _drawBubble = (ranges,width,height,_graph,data,gdata,container) ->
      x = d3.scale.linear().domain([ranges.xMin,ranges.xMax]).range([ 0, width ])
      y = d3.scale.linear().domain([ranges.yMin,ranges.yMax]).range([ height, 0 ])
      xAxis = d3.svg.axis().scale(x).orient('bottom')
      yAxis = d3.svg.axis().scale(y).orient('left')

      r = d3.scale.linear()
      .domain([d3.min(data, (d)-> parseFloat d.z), d3.max(data, (d)-> parseFloat d.z)])
      .range([3,15])

      rValue = (d)->parseFloat d.z

      tooltip = container
      .append('div')
      .attr('class', 'tooltip')
    #          .style('opacity', 0)

    # x axis
      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
      .append('text')
      .attr('class', 'label')
      .attr('x', width)
      .attr('y', -6)
    #          .style('text-anchor', 'end')
      .text gdata.xLab.value

    # y axis
      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr('class', 'label')
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
    #          .style("text-anchor", "end")
      .text gdata.yLab.value


    # create circle
      _graph.selectAll('.circle')
      .data(data)
      .enter().append('circle')
      .attr('fill', 'yellow')
      .attr('opacity', '0.7')
      .attr('stroke', 'orange')
      .attr('stroke-width', '2px')
      .attr('cx', (d) -> x d.x)
      .attr('cy', (d) -> y d.y)
      .attr('r', (d) -> r d.z)
      .on('mouseover', (d) ->
        tooltip.transition().duration(200).style('opacity', .9)
        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+gdata.zLab.value+': '+ rValue(d)+'</div>')
        .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
      .on('mouseout', () ->
        tooltip. transition().duration(500).style('opacity', 0))
    drawBubble: _drawBubble
]

.factory 'bar', [
  () ->
    _drawBar = (width,height,data,_graph,gdata) ->
      x = d3.scale.linear().range([ 0, width ])
      y = d3.scale.linear().range([ height, 0 ])
      xAxis = d3.svg.axis().scale(x).orient('bottom')
      yAxis = d3.svg.axis().scale(y).orient('left')
      x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
      y.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.y)])

      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call xAxis
      .append('text')
      .attr('class', 'label')
      .attr('x', width)
      .attr('y', 30)
    #          .style('text-anchor', 'end')
      .text gdata.xLab.value

      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
    #          .style("text-anchor", "end")
      .text "Count"

    # create bar elements
      _graph.selectAll('rect')
      .data(data)
      .enter().append('rect')
      .attr('class', 'bar')
      .attr('x',(d)-> x d.x  )
      .attr('width', 30)
      .attr('y', (d)-> y d.y )
      .attr('height', (d)-> (height - y d.y) )
      .attr('fill', 'steelblue')
    drawBar: _drawBar
]

.directive 'd3Charts', [
  'scatterplot',
  'histogram',
  'pie',
  'bubble',
  'bar'
  (scatterplot,histogram,pie,bubble,bar) ->
    restrict: 'E'
    template: "<div class='graph-container' style='height: 600px'></div>"
    link: (scope, elem, attr) ->
      margin = {top: 10, right: 40, bottom: 30, left:40}
      width = 750 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      svg = null
      data = null
      _graph = null
      container = null
      gdata = null
      ranges = null

      scope.$watch 'chartData', (newChartData) ->
        if newChartData
          gdata = newChartData
          data = newChartData.data

          #id = '#'+ newInfo.name
          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()
          svg = container.append('svg').attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom)
          #svg.select("#remove").remove()
          _graph = svg.append('g').attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          ranges =
            xMin: d3.min data, (d) -> parseFloat d.x
            yMin: d3.min data, (d) -> parseFloat d.y

            xMax: d3.max data, (d) -> parseFloat d.x
            yMax: d3.max data, (d) -> parseFloat d.y

          switch gdata.name
            when 'Bar Graph'
              bar.drawBar(width,height,data,_graph,gdata)
            when 'Bubble Chart'
              bubble.drawBubble(ranges,width,height,_graph,data,gdata,container)
            when 'Histogram'
              histogram.drawHist(_graph,data,container,gdata,width,height)
            when 'Pie Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              pie.drawPie(data,width,height,_graph)
            when 'Scatter Plot'
              scatterplot.drawScatterplot(data,ranges,width,height,_graph,container,gdata)
  ]


