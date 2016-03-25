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
      x: true
      y: true
      z: false
      message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
    ,
      name: 'Scatter Plot'
      value: 1
      x: true
      y: true
      z: false
      message: "Choose an x variable and a y variable."
    ,
      name: 'Histogram'
      value: 2
      x: true
      y: false
      z: false
      message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
    ,
      name: 'Bubble Chart'
      value: 3
      x: true
      y: true
      z: true
      message: "Choose an x variable, a y variable and a radius variable."
    ,
      name: 'Pie Chart'
      value: 4
      x: true
      y: false
      z: false
      message: "Choose one variable to put into a pie chart."
    ,

      name: 'Area Chart'
      value: 5
      x: true
      y: true
      z: false
      message: "Pick date variable for x and numerical variable for y"
    ,
      name: 'Stream Graph'
      value: 6
      x: true
      y: true
      z: true
      message: "Choose two numerical variables"
    ,
      name: 'Treemap'
      value: 7
      x: true
      y: false
      z: false
      message: "Choose one variable to construct Treemap."
    ,
      name: 'Line Chart'
      value: 8
      x: true
      y: true
      z: false
      message: "Choose a continuous variable for x and a numerical variable for y"
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
              x:  _chartData[$scope.graphInfo.x][i].value
            obj.push tmp

        else if $scope.graphInfo.y isnt "" and $scope.graphInfo.z is ""
          obj = []

          for i in [1...len] by 1
            tmp =
              x:  _chartData[$scope.graphInfo.x][i].value
              y:  _chartData[$scope.graphInfo.y][i].value
            obj.push tmp

        else
          obj = []

          for i in [1...len] by 1
            tmp =
              x:  _chartData[$scope.graphInfo.x][i].value
              y:  _chartData[$scope.graphInfo.y][i].value
              z:  _chartData[$scope.graphInfo.z][i].value
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

    $scope.labelVar = false
    $scope.labelCheck = null
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

.factory 'line', [
  () ->
    _lineChart = (data,ranges,width,height,_graph, gdata) ->
      formatDate = d3.time.format("%d-%b-%y")

      for d in data
        d.x = formatDate.parse(d.x)
        d.y = +d.y

      x = d3.time.scale()
      .range([0, width])

      y = d3.scale.linear()
      .range([height, 0])

      xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")

      yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")

      line = d3.svg.line()
      .x((d) -> x(d.x))
      .y((d) -> y(d.y))

      x.domain(d3.extent(data,  (d) -> d.x))
      y.domain(d3.extent(data,  (d) -> d.y))

      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text gdata.yLab.value

      _graph.append("path")
      .datum(data)
      .attr("class", "line")
      .attr("d", line)

    lineChart: _lineChart
]
.factory 'streamGraph', [
  () ->

    _randomSample  = (data, n) ->
#take an array of objects, and the desired number of random ones. return array of objects
      for d in data
        d.x = +d.x
        d.y = +d.y

      random = []
      for i in [0...n-1] by 1
        random.push(data[Math.floor(Math.random() * data.length)]) #picks random objects from data
      console.log random
      return random

    _streamGraph = (data,ranges,width,height,_graph) ->
      n = 20
      m = 100
      test = [_randomSample(data,m), _randomSample(data,m),_randomSample(data,m)]
      console.log test


      stack = d3.layout.stack()(test)

      dataset = [
        x: 5
        y:7
      ,
        x:8
        y:10
      ,
        x:14
        y:2

      ]

      #      layers = stack(dataset)
      #      console.log data
      #      console.log test
      #      #layers = stack(test)
      #      layers = stack(d3.range(n).map () -> _randomSample(data,m))
      #      console.log layers
      #      #console.log stack
      x = d3.scale.linear()
      .domain([0, m - 1])
      .range([0, width]);
      #
      y = d3.scale.linear()
      .domain([0, d3.max(test, (t)-> d3.max(t, (d) -> return d.y0+d.y))])
      .range([height, 0])
      #
      color = d3.scale.linear()
      .range(["#aad", "#556"])
      #
      area = d3.svg.area()
      .x((d) -> x d.x)
      .y0((d) -> y d.y0)
      .y1((d) -> y(d.y0 + d.y))

      _graph.selectAll("path")
      .data(test)
      .enter().append("path")
      .attr("d", area)
      .style("fill", () -> color(Math.random()))


    _streamGraph2 = (data,ranges,width,height,_graph) ->
      parseDate = d3.time.format("%m/%d/%y").parse
      console.log parseDate data[0].x



      stack = d3.layout.stack()
      .offset("silhouette")
      .values((d) -> d.values)
      .x((d) -> d.x)
      .y((d) -> d.y)

      x = d3.time.scale()
      .range([0, width]);

      y = d3.scale.linear()
      .range([height-10, 0]);

      z = d3.scale.ordinal()
      .range(["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"])

      console.log data

      area = d3.svg.area()
      .interpolate("cardinal")
      .x((d)-> x(d.x))
      .y0((d)-> y(d.y0))
      .y1((d)->y(d.y0 + d.y))

      nest = d3.nest().key (d) -> d.z


      for d in data
        d.x = parseDate d.x
        d.y = +d.y


      layers = stack(nest.entries(data))

      x.domain(d3.extent(data, (d)-> d.x))
      y.domain([0, d3.max(data, (d) -> d.y0 + d.y)])

      console.log layers

      _graph.selectAll("path")
      .data(layers)
      .enter().append("path")
      .attr("d", (d) -> area(d.values))
      .style("fill", (d,i) -> z(i))

    streamGraph: _streamGraph
    streamGraph2: _streamGraph2
]


.factory 'scatterPlot', [
  () ->
    _drawScatterPlot = (data,ranges,width,height,_graph,container,gdata) ->

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
      #cValue = (d)-> d.y
      #color = d3.scale.category10()

      # x axis
      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call xAxis
      .append('text')
      .attr('class', 'label')
      .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
      .text gdata.xLab.value

      # y axis
      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr('class', 'label')
      .attr("transform", "rotate(-90)")
      .attr('y', -50 )
      .attr('x', -(height / 2))
      .attr("dy", ".71em")
      .text gdata.yLab.value

      # add the tooltip area to the webpage
      tooltip = container
      .append('div')
      .attr('class', 'tooltip')

      # draw dots
      _graph.selectAll('.dot')
      .data(data)
      .enter().append('circle')
      .attr('class', 'dot')
      .attr('r', 5)
      .attr('cx', xMap)
      .attr('cy', yMap)
      .style('fill', 'DodgerBlue')
      .attr('opacity', '0.5')
      .on('mouseover', (d)->
        tooltip.transition().duration(200).style('opacity', .9)
        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">(' + xValue(d)+ ',' + yValue(d) + ')</div>')
        .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
      .on('mouseout', (d)->
        tooltip. transition().duration(500).style('opacity', 0))

    drawScatterPlot: _drawScatterPlot
]

.factory 'histogram',[
  () ->
    _drawHist = (_graph,data,container,gdata,width,height,ranges) ->
      container.append('input').attr('id', 'slider').attr('type','range').attr('min', '1').attr('max','10').attr('step', '1').attr('value','5')

      bins = null
      dataHist = null

      arr = data.map (d) -> parseFloat d.x
      x = d3.scale.linear().domain([ranges.xMin, ranges.xMax]).range([0,width])

      plotHist = (bins) ->
        $('#slidertext').remove()
        container.append('text').attr('id', 'slidertext').text('Bin Slider: '+bins).attr('position','relative').attr('left', '50px')
        dataHist = d3.layout.histogram().bins(bins)(arr)

        y = d3.scale.linear().domain([0,d3.max dataHist.map (i) -> i.length]).range([height,0])

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
        .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
        .text gdata.xLab.value

        # y axis
        _graph.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr('class', 'label')
        .attr("transform", "rotate(-90)")
        .attr('y', -50 )
        .attr('x', -(height / 2))
        .attr("dy", ".71em")
        .text "Count"

        bar = _graph.selectAll('.bar')
        .data(dataHist)

        bar.enter()
        .append("g")

        rect_width = width/bins
        bar.append('rect')
        .attr('x', (d) -> x d.x)
        .attr('y', (d) -> height - y d.y)
        .attr('width', rect_width)
        .attr('height', (d) -> y d.y)
        .attr("stroke","white")
        .attr("stroke-width",1)
        .on('mouseover', () -> d3.select(this).transition().style('fill', 'orange'))
        .on('mouseout', () -> d3.select(this).transition().style('fill', 'steelblue'))

        bar.append('text')
        .attr('x', (d) -> x d.x)
        .attr('y', (d) -> height - y d.y)
        .attr('dx', (d) -> .5*rect_width)
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
    valueSum = 0
    makePieData = (data) ->
      valueSum = 0
      counts = {}
      if(!isNaN(data[0].x)) # data is number
        pieMax = d3.max(data, (d)-> parseFloat d.x)
        pieMin = d3.min(data, (d)-> parseFloat d.x)
        maxPiePieces = 7  # set magic constant to variable
        rangeInt = Math.ceil((pieMax - pieMin) / maxPiePieces)
        counts = {}
        for val in data
          index = Math.floor((val.x - pieMin) / rangeInt)
          groupName = index + "-" + (index + rangeInt)
          #console.log groupName
          counts[groupName] = counts[groupName] || 0
          counts[groupName]++
          valueSum++
      else # data is string
        for i in [0..data.length-1] by 1
          currentVar = data[i].x
          counts[currentVar] = counts[currentVar] || 0
          counts[currentVar]++
          valueSum++

      obj = d3.entries counts
      return obj

    _drawPie = (data,width,height,_graph) ->
      radius = Math.min(width, height) / 2
      arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(0)

      #color = d3.scale.ordinal().range(["#ffffcc","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#0c2c84"])
      color = d3.scale.category20c()
      arcOver = d3.svg.arc()
      .outerRadius(radius + 10)

      pie = d3.layout.pie()
      .value((d)-> d.value)
      .sort(null)

      formatted_data = makePieData(data)

      arcs = _graph.selectAll(".arc")
      .data(pie(formatted_data))
      .enter()
      .append('g')
      .attr("class", "arc")

      arcs.append('path')
      .attr('d', arc)
      .attr('fill', (d) -> color(d.data.value))
      .on('mouseenter', (d) -> d3.select(this).attr("stroke","white") .transition().attr("d", arcOver).attr("stroke-width",3))
      .on('mouseleave', (d) -> d3.select(this).transition().attr('d', arc).attr("stroke", "none"))

      arcs.append('text')
      .attr('id','tooltip')
      .attr('transform', (d) -> 'translate('+arc.centroid(d)+')')
      .attr('text-anchor', 'middle')
      .text (d) -> d.data.key + ': ' + parseFloat(100*d.data.value/valueSum).toFixed(2) + '%'

    drawPie: _drawPie
]

.factory 'bubble', [
  () ->
    _drawBubble = (ranges,width,height,_graph,data,gdata,container) ->
      x = d3.scale.linear().domain([ranges.xMin,ranges.xMax]).range([ 0, width ])
      y = d3.scale.linear().domain([ranges.yMin,ranges.yMax]).range([ height, 0 ])
      xAxis = d3.svg.axis().scale(x).orient('bottom')
      yAxis = d3.svg.axis().scale(y).orient('left')

      zIsNumber = !isNaN(data[0].z)

      r = 0
      rValue = 0
      if(zIsNumber)
        r = d3.scale.linear()
        .domain([d3.min(data, (d)-> parseFloat d.z), d3.max(data, (d)-> parseFloat d.z)])
        .range([3,15])
        rValue = (d) -> parseFloat d.z
      else
        r = d3.scale.linear()
        .domain([5, 5])
        .range([3,15])
        rValue = (d) -> d.z

      tooltip = container
      .append('div')
      .attr('class', 'tooltip')

      color = d3.scale.category10()

      # x axis
      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)
      .append('text')
      .attr('class', 'label')
      .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
      .text gdata.xLab.value

      # y axis
      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
      .attr('class', 'label')
      .attr("transform", "rotate(-90)")
      .attr('y', -50 )
      .attr('x', -(height / 2))
      .attr("dy", ".71em")
      .text gdata.yLab.value

      # create circle
      _graph.selectAll('.circle')
      .data(data)
      .enter().append('circle')
      .attr('fill',
        if(zIsNumber)
          'yellow'
        else
          (d) -> color(d.z))
      .attr('opacity', '0.7')
      .attr('stroke',
        if(zIsNumber)
          'orange'
        else
          (d) -> color(d.z))
      .attr('stroke-width', '2px')
      .attr('cx', (d) -> x d.x)
      .attr('cy', (d) -> y d.y)
      .attr('r', (d) ->
        if(zIsNumber) # if d.z is number, use d.z as radius
          r d.z
        else # else, set radius to be 8
          8)
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
    _setAxisPar = (x,y,xAxis,yAxis,type, width, height) ->
      ord = d3.scale.ordinal()
      lin = d3.scale.linear()

      switch type
        when "xCat" or "xCatAndyNum"
          x = ord.rangeRoundBands([0, width], .1)
          y = lin.range([ height, 0 ])
        when "xNum" or "xNumAndyCat"
          x = lin.range([ 0, width ])
          y = ord.rangeRoundBands([height, 0], .1)
        when "xNumAndyNum"
          x = lin.range([ 0, width ])
          y = lin.range([ height, 0 ])
        else
          alert "Two categorical variables"


      xAxis = d3.svg.axis().scale(x).orient('bottom')
      yAxis = d3.svg.axis().scale(y).orient('left')

    _drawBar = (width,height,data,_graph,gdata) ->
      x = d3.scale.linear().range([ 0, width ])
      y = d3.scale.linear().range([ height, 0 ])


      xAxis = d3.svg.axis().scale(x).orient('bottom')
      yAxis = d3.svg.axis().scale(y).orient('left')
      x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
      y.domain([d3.min(data, (d)->parseFloat d.y), d3.max(data, (d)->parseFloat d.y)])

      #without y
      if !data[0].y
#Works
        if isNaN data[0].x
          counts = {}
          for i in [0..data.length-1] by 1
            currentVar = data[i].x
            counts[currentVar] = counts[currentVar] || 0
            counts[currentVar]++
          counts = d3.entries counts
          #          console.log counts
          x = d3.scale.ordinal().rangeRoundBands([0, width], .1)
          xAxis = d3.svg.axis().scale(x).orient('bottom')
          x.domain(counts.map (d) -> d.key)
          y.domain([d3.min(counts, (d)-> parseFloat d.value), d3.max(counts, (d)-> parseFloat d.value)])

          _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + height + ')')
          .call xAxis
          .append('text')
          .attr('class', 'label')
          .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
          .text gdata.xLab.value

          _graph.append('g')
          .attr('class', 'y axis')
          .call yAxis
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('y', -50 )
          .attr('x', -(height / 2))
          .attr('dy', '1em')
          .text "Count"

          # create bar elements
          _graph.selectAll('rect')
          .data(counts)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('x',(d)-> x d.key  )
          .attr('width', x.rangeBand())
          .attr('y', (d)-> y d.value )
          .attr('height', (d)-> Math.abs(height - y d.value))
          .attr('fill', 'steelblue')


        else #data is numerical and only x. height is rect width, width is x of d.x,
#y becomes the categorical
          y = d3.scale.ordinal().rangeRoundBands([height, 0], .1)
          yAxis = d3.svg.axis().scale(y).orient('left')

          y.domain((d) -> d.x)

          _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + height + ')')
          .call xAxis
          .append('text')
          .attr('class', 'label')
          .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
          .text gdata.xLab.value

          _graph.append('g')
          .attr('class', 'y axis')
          .call yAxis
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr('y', -50 )
          .attr('x', -(height / 2))
          .attr('dy', '1em')
          .text "Null"

          rectWidth = height/data.length
          # create bar elements
          _graph.selectAll('rect')
          .data(data)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('width', (d)-> x d.x)
          .attr('y', (d,i)-> i*rectWidth)
          .attr('height', rectWidth)
          .attr('fill', 'steelblue')



#with y
      else
#y is categorical
        if isNaN data[0].y

          y = d3.scale.ordinal().rangeRoundBands([0, height], .1)
          y.domain(data.map (d) -> d.y)
          yAxis = d3.svg.axis().scale(y).orient('left')

          _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + height + ')')
          .call xAxis
          .append('text')
          .attr('class', 'label')
          .attr('x', width-80)
          .attr('y', 30)
          .text gdata.xLab.value

          _graph.append('g')
          .attr('class', 'y axis')
          .call yAxis
          .append('text')
          .attr('transform', 'rotate(-90)')
          .attr("x", -80)
          .attr("y", -40)
          .attr('dy', '1em')
          .text gdata.yLab.value

          _graph.selectAll('rect')
          .data(data)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('width', (d) -> Math.abs(x d.x))
          .attr('y', (d)-> y d.y )
          .attr('height', y.rangeBand())
          .attr('fill', 'steelblue')


        else if !isNaN data[0].y
          if isNaN data[0].x
            console.log "xCat and yNum"
            x = d3.scale.ordinal().rangeRoundBands([0, width], .1)
            x.domain(data.map (d) -> d.x)
            xAxis = d3.svg.axis().scale(x).orient('bottom')
            #y.domain([d3.min(data, (d)-> parseFloat d.y), d3.max(data, (d)-> parseFloat d.y)])

            _graph.append('g')
            .attr('class', 'x axis')
            .attr('transform', 'translate(0,' + height + ')')
            .call xAxis
            .append('text')
            .attr('class', 'label')
            .attr('transform', 'translate(' + (width / 2) + ',' + 40 + ')')
            .text gdata.xLab.value

            _graph.append('g')
            .attr('class', 'y axis')
            .call yAxis
            .append('text')
            .attr('transform', 'rotate(-90)')
            .attr('y', -50 )
            .attr('x', -(height / 2))
            .attr('dy', '1em')
            .text "Count"

            # create bar elements
            _graph.selectAll('rect')
            .data(data)
            .enter().append('rect')
            .attr('class', 'bar')
            .attr('x',(d)-> x d.x  )
            .attr('width', x.rangeBand())
            .attr('y', (d)-> y d.y )
            .attr('height', (d)-> Math.abs(height - y d.y))
            .attr('fill', 'steelblue')
          else

#else if !isNaN data[0].y and !isNaN data[0].x
            rectWidth = width / data.length

            _graph.append('g')
            .attr('class', 'x axis')
            .attr('transform', 'translate(0,' + height + ')')
            .call xAxis
            .append('text')
            .attr('class', 'label')
            .attr('x', width-80)
            .attr('y', 30)
            .text gdata.xLab.value

            _graph.append('g')
            .attr('class', 'y axis')
            .call yAxis
            .append('text')
            .attr('transform', 'rotate(-90)')
            .attr("x", -80)
            .attr("y", -40)
            .attr('dy', '1em')
            .text gdata.yLab.value


            # create bar elements
            _graph.selectAll('rect')
            .data(data)
            .enter().append('rect')
            .attr('class', 'bar')
            .attr('x',(d)-> x d.x  )
            .attr('width', rectWidth)
            .attr('y', (d)-> y d.y )
            .attr('height', (d)-> Math.abs(height - y d.y) )
            .attr('fill', 'steelblue')

    drawBar: _drawBar
]



.factory 'area',[
  ()->
    _drawArea = (height,width,_graph, data,gdata) ->
      parseDate = d3.time.format("%d-%b-%y").parse

      for d in data
        d.x = parseDate d.x
        d.y = +d.y
      x = d3.time.scale().range([ 0, width ])
      y = d3.scale.linear().range([ height, 0 ])
      xAxis = d3.svg.axis().scale(x).orient("bottom")
      yAxis = d3.svg.axis().scale(y).orient("left")
      area = d3.svg.area().x((d) ->
        x d.x
      ).y0(height).y1((d) ->
        y d.y
      )
      #  svg = d3.select("body").append("svg").attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom).append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")")

      x.domain d3.extent(data, (d) ->
        d.x
      )
      y.domain [ 0, d3.max(data, (d) ->
        d.y
      ) ]
      _graph.append("path")
      .datum(data)
      .attr("class", "area")
      .attr "d", area
      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call xAxis

      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis).append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6).attr("dy", ".71em")
      .style("text-anchor", "end")
      .text gdata.yLab.value


    drawArea: _drawArea
]


.factory 'treemap',[
  () ->
    _drawTreemap = (svg, width, height, margin) ->
      data =   {"name": "SOCR", "url": "http://www.socr.ucla.edu/", "size": 35000,"children":

                [ {"name": "Get Started", "url": "http://wiki.stat.ucla.edu/socr/index.php/Main_Page", "size": 23333.333333333332,"children":
                  [{"name": "Tutorial Videos", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Videos", "size": 15555.555555555555},
                    {"name": "Help Pages", "url": "http://wiki.socr.umich.edu/index.php/SOCR_Help_Pages", "size": 15555.555555555555},
                    {"name": "Downloads", "url": "http://socr.umich.edu/html/SOCR_Download.html", "size": 15555.555555555555}
                  ]
                },

                  {"name": "Java Applets", "url": "http://socr.umich.edu/index.html", "size": 23333.333333333332,"children":
                    [ {"name": "Web-Start Applications", "url": "http://socr.ucla.edu/webstart/index.html", "size": 15555.555555555555},
                      {"name": "Distributions", "url": "../../SOCR_Distributions.html", "size": 15555.555555555555,"children":
                        [{"name": "Anderson-Darling Distribution", "url": "http://socr.ucla.edu/htmls/dist/AndersonDarling_Distribution.html", "size": 10370.37037037037},
                          {"name": "ArcSine Distribution", "url": "http://socr.ucla.edu/htmls/dist/ArcSine_Distribution.html", "size": 10370.37037037037},
                          {"name": "Benford Distribution", "url": "http://socr.ucla.edu/htmls/dist/Benford_Distribution.html", "size": 10370.37037037037},
                          {"name": "Bernoulli Distribution", "url": "http://socr.ucla.edu/htmls/dist/Bernoulli_Distribution.html", "size": 10370.37037037037},
                          {"name": "Beta Distribution", "url": "http://socr.ucla.edu/htmls/dist/Beta_Distribution.html", "size": 10370.37037037037},
                          {"name": "Beta (Generalized) Distribution", "url": "http://socr.ucla.edu/htmls/dist/BetaGeneral_Distribution.html", "size": 10370.37037037037},
                          {"name": "Beta-Binomial Distribution", "url": "http://socr.ucla.edu/htmls/dist/BetaBinomial_Distribution.html", "size": 10370.37037037037},
                          {"name": "Binomial Distribution", "url": "http://socr.ucla.edu/htmls/dist/Binomial_Distribution.html", "size": 10370.37037037037},
                          {"name": "Birthday Distribution", "url": "http://socr.ucla.edu/htmls/dist/Birthday_Distribution.html", "size": 10370.37037037037},
                          {"name": "(3D) Bivariate Normal Distribution", "url": "http://socr.ucla.edu/htmls/HTML5/BivariateNormal/", "size": 10370.37037037037},
                          {"name": "Cauchy Distribution", "url": "http://socr.ucla.edu/htmls/dist/Cauchy_Distribution.html", "size": 10370.37037037037},
                          {"name": "Chi Distribution", "url": "http://socr.ucla.edu/htmls/dist/Chi_Distribution.html", "size": 10370.37037037037},
                          {"name": "Chi-Square Distribution", "url": "http://socr.ucla.edu/htmls/dist/ChiSquare_Distribution.html", "size": 10370.37037037037},
                          {"name": "(Non-Central) Chi-Square Distribution", "url": "http://socr.ucla.edu/htmls/dist/NonCentralChiSquare_Distribution.html", "size": 10370.37037037037},
                          {"name": "Circle Distribution", "url": "http://socr.ucla.edu/htmls/dist/Circle_Distribution.html", "size": 10370.37037037037},
                          {"name": "Continuous Uniform Distribution", "url": "http://socr.ucla.edu/htmls/dist/ContinuousUniform_Distribution.html", "size": 10370.37037037037},
                          {"name": "Coupon Distribution", "url": "http://socr.ucla.edu/htmls/dist/Coupon_Distribution.html", "size": 10370.37037037037},
                          {"name": "Die Distribution", "url": "http://socr.ucla.edu/htmls/dist/Die_Distribution.html", "size": 10370.37037037037},
                          {"name": "Discrete ArcSine Distribution", "url": "http://socr.ucla.edu/htmls/dist/DiscreteArcSine_Distribution.html", "size": 10370.37037037037},
                          {"name": "Discrete Uniform Distribution", "url": "http://socr.ucla.edu/htmls/dist/DiscreteUniform_Distribution.html", "size": 10370.37037037037},
                          {"name": "Erlang Distribution", "url": "http://socr.ucla.edu/htmls/dist/Erlang_Distribution.html", "size": 10370.37037037037},
                          {"name": "Error Distribution", "url": "http://socr.ucla.edu/htmls/dist/Error_Distribution.html", "size": 10370.37037037037},
                          {"name": "Exponential Distribution", "url": "http://socr.ucla.edu/htmls/dist/Exponential_Distribution.html", "size": 10370.37037037037},
                          {"name": "FiniteDistribution", "url": "http://socr.ucla.edu/htmls/dist/Finite_Distribution.html", "size": 10370.37037037037},
                          {"name": "Fisher's F Distribution", "url": "http://socr.ucla.edu/htmls/dist/Fisher_Distribution.html", "size": 10370.37037037037},
                          {"name": "Fisher-Tippett Distribution", "url": "http://socr.ucla.edu/htmls/dist/FisherTippett_Distribution.html", "size": 10370.37037037037},
                          {"name": "Gamma Distribution", "url": "http://socr.ucla.edu/htmls/dist/Gamma_Distribution.html", "size": 10370.37037037037},
                          {"name": "General Cauchy Distribution", "url": "http://socr.ucla.edu/htmls/dist/GeneralCauchy_Distribution.html", "size": 10370.37037037037},
                          {"name": "Generalized Extreme Value (GEV) Distribution", "url": "http://socr.ucla.edu/htmls/dist/GeneralizedExtremeValue_Distribution.html", "size": 10370.37037037037},
                          {"name": "Geometric Distribution", "url": "http://socr.ucla.edu/htmls/dist/Geometric_Distribution.html", "size": 10370.37037037037},
                          {"name": "Gilbrats Distribution", "url": "http://socr.ucla.edu/htmls/dist/Gilbrats_Distribution.html", "size": 10370.37037037037},
                          {"name": "Gompertz Distribution", "url": "http://socr.ucla.edu/htmls/dist/Gompertz_Distribution.html", "size": 10370.37037037037},
                          {"name": "Gumbel Distribution", "url": "http://socr.ucla.edu/htmls/dist/Gumbel_Distribution.html", "size": 10370.37037037037},
                          {"name": "Half-Normal Distribution", "url": "http://socr.ucla.edu/htmls/dist/HalfNormal_Distribution.html", "size": 10370.37037037037},
                          {"name": "HyperGeometric Distribution", "url": "http://socr.ucla.edu/htmls/dist/HyperGeometric_Distribution.html", "size": 10370.37037037037},
                          {"name": "Hyperbolic-Secant Distribution", "url": "http://socr.ucla.edu/htmls/dist/HyperbolicSecant_Distribution.html", "size": 10370.37037037037},
                          {"name": "Inverse-Gamma Distribution", "url": "http://socr.ucla.edu/htmls/dist/InverseGamma_Distribution.html", "size": 10370.37037037037},
                          {"name": "Inverse Gaussian (Wald) Distribution", "url": "http://socr.ucla.edu/htmls/dist/InverseGaussian_Distribution.html", "size": 10370.37037037037},
                          {"name": "Johnson SB (Bounded) Distribution", "url": "http://socr.ucla.edu/htmls/dist/JohnsonSBDistribution.html", "size": 10370.37037037037},
                          {"name": "Johnson SU (Unbounded) Distribution", "url": "http://socr.ucla.edu/htmls/dist/JohnsonSUDistribution.html", "size": 10370.37037037037},
                          {"name": "Kolmogorov Distribution", "url": "http://socr.ucla.edu/htmls/dist/Kolmogorov_Distribution.html", "size": 10370.37037037037},
                          {"name": "Laplace Distribution", "url": "http://socr.ucla.edu/htmls/dist/Laplace_Distribution.html", "size": 10370.37037037037},
                          {"name": "Logarithmic-Series Distribution", "url": "http://socr.ucla.edu/htmls/dist/LogarithmicSeries_Distribution.html", "size": 10370.37037037037},
                          {"name": "Logistic Distribution", "url": "http://socr.ucla.edu/htmls/dist/Logistic_Distribution.html", "size": 10370.37037037037},
                          {"name": "Logistic-Exponential Distribution", "url": "http://socr.ucla.edu/htmls/dist/LogisticExponential_Distribution.html", "size": 10370.37037037037},
                          {"name": "Log-Normal Distribution", "url": "http://socr.ucla.edu/htmls/dist/LogNormal_Distribution.html", "size": 10370.37037037037},
                          {"name": "Lomax Distribution", "url": "http://socr.ucla.edu/htmls/dist/Lomax_Distribution.html", "size": 10370.37037037037},
                          {"name": "Matching Distribution", "url": "http://socr.ucla.edu/htmls/dist/Matching_Distribution.html", "size": 10370.37037037037},
                          {"name": "Maxwell Distribution", "url": "http://socr.ucla.edu/htmls/dist/Maxwell_Distribution.html", "size": 10370.37037037037},
                          {"name": "Minimax Distribution", "url": "http://socr.ucla.edu/htmls/dist/Minimax_Distribution.html", "size": 10370.37037037037},
                          {"name": "Mixture Distribution", "url": "http://socr.ucla.edu/htmls/dist/Mixture_Distribution.html", "size": 10370.37037037037},
                          {"name": "Multinomial Distribution", "url": "http://socr.ucla.edu/htmls/dist/Multinomial_Distribution.html", "size": 10370.37037037037},
                          {"name": "Muth Distribution", "url": "http://socr.ucla.edu/htmls/dist/Muth_Distribution.html", "size": 10370.37037037037},
                          {"name": "Negative-Binomial Distribution", "url": "http://socr.ucla.edu/htmls/dist/NegativeBinomial_Distribution.html", "size": 10370.37037037037},
                          {"name": "Negative-HyperGeometric Distribution", "url": "http://socr.ucla.edu/htmls/dist/NegativeHypergeometric_Distribution.html", "size": 10370.37037037037},
                          {"name": "Negative-Multinomial Distribution", "url": "http://socr.ucla.edu/htmls/dist/NegativeMultinomial_Distribution.html", "size": 10370.37037037037},
                          {"name": "Normal Distribution", "url": "http://socr.ucla.edu/htmls/dist/Normal_Distribution.html", "size": 10370.37037037037},
                          {"name": "Pareto Distribution", "url": "http://socr.ucla.edu/htmls/dist/Pareto_Distribution.html", "size": 10370.37037037037},
                          {"name": "Point-Mass Distribution", "url": "http://socr.ucla.edu/htmls/dist/PointMass_Distribution.html", "size": 10370.37037037037},
                          {"name": "Poisson Distribution", "url": "http://socr.ucla.edu/htmls/dist/Poisson_Distribution.html", "size": 10370.37037037037},
                          {"name": "Poker-Dice Distribution", "url": "http://socr.ucla.edu/htmls/dist/PokerDice_Distribution.html", "size": 10370.37037037037},
                          {"name": "Power-Function Distribution", "url": "http://socr.ucla.edu/htmls/dist/PowerFunction_Distribution.html", "size": 10370.37037037037},
                          {"name": "Rayleigh Distribution", "url": "http://socr.ucla.edu/htmls/dist/Rayleigh_Distribution.html", "size": 10370.37037037037},
                          {"name": "Rice (Rician) Distribution", "url": "http://socr.ucla.edu/htmls/dist/Rice_Distribution.html", "size": 10370.37037037037},
                          {"name": "Student's T Distribution", "url": "http://socr.ucla.edu/htmls/dist/StudentT_Distribution.html", "size": 10370.37037037037},
                          {"name": "Student's T Non-Central Distribution", "url": "http://socr.ucla.edu/htmls/dist/StudentT_Distribution.html", "size": 10370.37037037037},
                          {"name": "Triangle Distribution", "url": "http://socr.ucla.edu/htmls/dist/Triangle_Distribution.html", "size": 10370.37037037037},
                          {"name": "Two-Sided Power Distribution", "url": "http://socr.ucla.edu/htmls/dist/TwoSidedPower_Distribution.html", "size": 10370.37037037037},
                          {"name": "U-Quadratic Distribution", "url": "http://socr.ucla.edu/htmls/dist/UQuadratic_Distribution.html", "size": 10370.37037037037},
                          {"name": "Von Mises Distribution", "url": "http://socr.ucla.edu/htmls/dist/VonMises_Distribution.html", "size": 10370.37037037037},
                          {"name": "WalkMaxDistribution", "url": "http://socr.ucla.edu/htmls/dist/WalkMax_Distribution.html", "size": 10370.37037037037},
                          {"name": "WalkPositionDistribution", "url": "http://socr.ucla.edu/htmls/dist/WalkPosition_Distribution.html", "size": 10370.37037037037},
                          {"name": "Weibull Distribution", "url": "http://socr.ucla.edu/htmls/dist/Weibull_Distribution.html", "size": 10370.37037037037},
                          {"name": "Zipf-Mandelbrot Distribution", "url": "http://socr.ucla.edu/htmls/dist/ZipfMandelbrot_Distribution.html", "size": 10370.37037037037}]},
                      {"name": "Experiments", "url": "../../exp", "size": 15555.555555555555,"children":
                        [{"name": "Ballot Experiment", "url": "http://socr.ucla.edu/htmls/exp/Ballot_Experiment.html", "size": 10370.37037037037},
                          {"name": "Ball and Urn Experiment", "url": "http://socr.ucla.edu/htmls/exp/Ball_and_Urn_Experiment.html", "size": 10370.37037037037},
                          {"name": "Bertrand Experiment", "url": "http://socr.ucla.edu/htmls/exp/Bertrand_Experiment.html", "size": 10370.37037037037},
                          {"name": "Beta Coin Experiment", "url": "http://socr.ucla.edu/htmls/exp/Beta_Coin_Experiment.html", "size": 10370.37037037037},
                          {"name": "Beta Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Beta_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Binomial Coin Experiment", "url": "http://socr.ucla.edu/htmls/exp/Binomial_Coin_Experiment.html", "size": 10370.37037037037},
                          {"name": "Binomial Timeline Experiment", "url": "http://socr.ucla.edu/htmls/exp/Binomial_Timeline_Experiment.html", "size": 10370.37037037037},
                          {"name": "Birthday Experiment", "url": "http://socr.ucla.edu/htmls/exp/Birthday_Experiment.html", "size": 10370.37037037037},
                          {"name": "Bivariate Normal Experiment", "url": "http://socr.ucla.edu/htmls/exp/Bivariate_Normal_Experiment.html", "size": 10370.37037037037},
                          {"name": "Bivariate Uniform Experiment", "url": "http://socr.ucla.edu/htmls/exp/Bivariate_Uniform_Experiment.html", "size": 10370.37037037037},
                          {"name": "Buffon's Coin Experiment", "url": "http://socr.ucla.edu/htmls/exp/Buffon_Coin_Experiment.html", "size": 10370.37037037037},
                          {"name": "Buffon's Needle Experiment", "url": "http://socr.ucla.edu/htmls/exp/Buffon_Needle_Experiment.html", "size": 10370.37037037037},
                          {"name": "Card Experiment", "url": "http://socr.ucla.edu/htmls/exp/Card_Experiment.html", "size": 10370.37037037037},
                          {"name": "Chi Square Dice Experiment", "url": "http://socr.ucla.edu/htmls/exp/Chi_Square_Dice_Experiment.html", "size": 10370.37037037037},
                          {"name": "Chuck A Luck Experiment", "url": "http://socr.ucla.edu/htmls/exp/Chuck_A_Luck_Experiment.html", "size": 10370.37037037037},
                          {"name": "Coin Die Experiment", "url": "http://socr.ucla.edu/htmls/exp/Coin_Die_Experiment.html", "size": 10370.37037037037},
                          {"name": "Coin Sample Experiment", "url": "http://socr.ucla.edu/htmls/exp/Coin_Sample_Experiment.html", "size": 10370.37037037037},
                          {"name": "Coin-Toss LLN Experiment", "url": "http://socr.ucla.edu/htmls/exp/Coin_Toss_LLN_Experiment.html", "size": 10370.37037037037},
                          {"name": "Confidence Interval Experiment", "url": "http://socr.ucla.edu/htmls/exp/Confidence_Interval_Experiment.html", "size": 10370.37037037037},
                          {"name": "Coupon Collector Experiment", "url": "http://wiki.socr.umich.edu/index.php/SOCR_EduMaterials_ExperimentsActivities", "size": 10370.37037037037},
                          {"name": "Craps Experiment", "url": "http://socr.ucla.edu/htmls/exp/Craps_Experiment.html", "size": 10370.37037037037},
                          {"name": "Dice Experiment", "url": "http://socr.ucla.edu/htmls/exp/Dice_Experiment.html", "size": 10370.37037037037},
                          {"name": "Dice Sample Experiment", "url": "http://socr.ucla.edu/htmls/exp/Dice_Sample_Experiment.html", "size": 10370.37037037037},
                          {"name": "Die Coin Experiment", "url": "http://socr.ucla.edu/htmls/exp/Die_Coin_Experiment.html", "size": 10370.37037037037},
                          {"name": "Exponential Car-Times Experiment", "url": "http://socr.ucla.edu/htmls/exp/Exponential-Times_Car_Experiment.html", "size": 10370.37037037037},
                          {"name": "Finite Order Statistic Experiment", "url": "http://socr.ucla.edu/htmls/exp/Finite_Order_Statistic_Experiment.html", "size": 10370.37037037037},
                          {"name": "Fire Experiment", "url": "http://socr.ucla.edu/htmls/exp/Fire_Experiment.html", "size": 10370.37037037037},
                          {"name": "Galton Board Experiment", "url": "http://socr.ucla.edu/htmls/exp/Galton_Board_Experiment.html", "size": 10370.37037037037},
                          {"name": "Gamma Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Gamma_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Gamma Experiment", "url": "http://socr.ucla.edu/htmls/exp/Gamma_Experiment.html", "size": 10370.37037037037},
                          {"name": "General CI Experiment", "url": "http://socr.ucla.edu/htmls/exp/Confidence_Interval_Experiment_General.html", "size": 10370.37037037037},
                          {"name": "LLN Simple Experiment", "url": "http://socr.ucla.edu/htmls/exp/LLN_Simple_Experiment.html", "size": 10370.37037037037},
                          {"name": "Markov Chain Experiment", "url": "http://socr.ucla.edu/htmls/exp/Markov_Chain_Experiment.html", "size": 10370.37037037037},
                          {"name": "Match Experiment", "url": "http://socr.ucla.edu/htmls/exp/Match_Experiment.html", "size": 10370.37037037037},
                          {"name": "Mean Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Mean_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Mean Test Experiment", "url": "http://socr.ucla.edu/htmls/exp/Mean_Test_Experiment.html", "size": 10370.37037037037},
                          {"name": "Mixture Model EM Experiment", "url": "http://socr.ucla.edu/htmls/exp/Mixture_Model_EM_Experiment.html", "size": 10370.37037037037},
                          {"name": "Monty Hall Experiment", "url": "http://socr.ucla.edu/htmls/exp/Monty_Hall_Experiment.html", "size": 10370.37037037037},
                          {"name": "Negative Binomial Experiment", "url": "http://socr.ucla.edu/htmls/exp/Negative_Binomial_Experiment.html", "size": 10370.37037037037},
                          {"name": "Normal Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Normal_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Order Statistics Experiment", "url": "http://socr.ucla.edu/htmls/exp/Order_Statistics_Experiment.html", "size": 10370.37037037037},
                          {"name": "Pareto Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Pareto_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Two-Dimensional Poisson Experiment", "url": "http://socr.ucla.edu/htmls/exp/Two-Dimensional_Poisson_Experiment.html", "size": 10370.37037037037},
                          {"name": "Poisson Experiment", "url": "http://socr.ucla.edu/htmls/exp/Poisson_Experiment.html", "size": 10370.37037037037},
                          {"name": "Two-Type Poisson Experiment", "url": "http://socr.ucla.edu/htmls/exp/Two-Type_Poisson_Experiment.html", "size": 10370.37037037037},
                          {"name": "Poker Dice Experiment", "url": "http://socr.ucla.edu/htmls/exp/Poker_Dice_Experiment.html", "size": 10370.37037037037},
                          {"name": "Poker Experiment", "url": "http://socr.ucla.edu/htmls/exp/Poker_Experiment.html", "size": 10370.37037037037},
                          {"name": "Probability Plot Experiment", "url": "http://socr.ucla.edu/htmls/exp/Probability_Plot_Experiment.html", "size": 10370.37037037037},
                          {"name": "Proportion Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Proportion_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Proportion Test Experiment", "url": "http://socr.ucla.edu/htmls/exp/Proportion_Test_Experiment.html", "size": 10370.37037037037},
                          {"name": "Random Experiment", "url": "http://socr.ucla.edu/htmls/exp/Random_Experiment.html", "size": 10370.37037037037},
                          {"name": "Random Variable Experiment", "url": "http://socr.ucla.edu/htmls/exp/Random_Variable_Experiment.html", "size": 10370.37037037037},
                          {"name": "Randowm Walk Experiment", "url": "http://socr.ucla.edu/htmls/exp/Random_Walk_Experiment.html", "size": 10370.37037037037},
                          {"name": "Red and Black Experiment", "url": "http://socr.ucla.edu/htmls/exp/Red_and_Black_Experiment.html", "size": 10370.37037037037},
                          {"name": "Roulette Experiment", "url": "http://socr.ucla.edu/htmls/exp/Roulette_Experiment.html", "size": 10370.37037037037},
                          {"name": "Sample Mean Experiment", "url": "http://socr.ucla.edu/htmls/exp/Sample_Mean_Experiment.html", "size": 10370.37037037037},
                          {"name": "Sample Distribution CLT Experiment", "url": "http://socr.ucla.edu/htmls/exp/Sampling_Distribution_CLT_Experiment.html", "size": 10370.37037037037},
                          {"name": "Sign Test Experiment", "url": "http://socr.ucla.edu/htmls/exp/Sign_Test_Experiment.html", "size": 10370.37037037037},
                          {"name": "Spinner Experiment", "url": "http://socr.ucla.edu/htmls/exp/Spinner_Experiment.html", "size": 10370.37037037037},
                          {"name": "Triangle Experiment", "url": "http://socr.ucla.edu/htmls/exp/Triangle_Experiment.html", "size": 10370.37037037037},
                          {"name": "Uniform Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Uniform_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Uniform E-Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Uniform_E-Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Variance Estimate Experiment", "url": "http://socr.ucla.edu/htmls/exp/Variance_Estimate_Experiment.html", "size": 10370.37037037037},
                          {"name": "Variance Test Experiment", "url": "http://socr.ucla.edu/htmls/exp/Variance_Test_Experiment.html", "size": 10370.37037037037},
                          {"name": "Voter Experiment", "url": "http://socr.ucla.edu/htmls/exp/Voter_Experiment.html", "size": 10370.37037037037}]},
                      {"name": "Analyses", "url": "../../ana/SOCR_Analyses.html", "size": 15555.555555555555,"children":
                        [{"name": "ANOVA 1-Way", "url": "http://socr.ucla.edu/htmls/ana/ANOVA1Way_Analysis.html", "size": 10370.37037037037},
                          {"name": "ANOVA 2-Way", "url": "http://socr.ucla.edu/htmls/ana/ANOVA2Way_Analysis.html", "size": 10370.37037037037},
                          {"name": "Chi-Square Contingency Tables", "url": "http://socr.ucla.edu/htmls/ana/ChiSquareCT_Analysis.html", "size": 10370.37037037037},
                          {"name": "Chi-Square Goodness of Fit", "url": "http://socr.ucla.edu/htmls/ana/ChiSquareGF_Analysis.html", "size": 10370.37037037037},
                          {"name": "Confidence Interval Analysis", "url": "http://www.socr.ucla.edu/htmls/ana/ConfidenceInterval_Analysis.html", "size": 10370.37037037037},
                          {"name": "Fisher's Exact Test", "url": "http://socr.ucla.edu/htmls/ana/FishersExactTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "Fligner-Killeen Test", "url": "http://www.socr.ucla.edu/htmls/ana/FlignerKilleen_Analysis.html", "size": 10370.37037037037},
                          {"name": "Friedman's Test", "url": "http://socr.ucla.edu/htmls/ana/FriedmansTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "Kolmogorov-Smirnoff Test", "url": "http://www.socr.ucla.edu/htmls/ana/KolmogorovSmirnoff_Analysis.html", "size": 10370.37037037037},
                          {"name": "Kruskal-Wallis Test", "url": "http://www.socr.ucla.edu/htmls/ana/KruskalWallis_Analysis.html", "size": 10370.37037037037},
                          {"name": "Hierarchical Clustrering", "url": "http://www.socr.ucla.edu/htmls/ana/HierarchicalClustering_Analysis.html", "size": 10370.37037037037},
                          {"name": "Losgistic Regression Test", "url": "http://www.socr.ucla.edu/htmls/ana/LogisticRegression_Analysis.html", "size": 10370.37037037037},
                          {"name": "Multiple Linear Regression", "url": "http://www.socr.ucla.edu/htmls/ana/MultipleRegression_Analysis.html", "size": 10370.37037037037},
                          {"name": "Normal Distribution Power Analysis", "url": "http://socr.ucla.edu/htmls/ana/NormalPower_Analysis.html", "size": 10370.37037037037},
                          {"name": "One-Sample T-Test", "url": "http://socr.ucla.edu/htmls/ana/OneSampleTTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "One-Sample Z-Test", "url": "http://www.socr.ucla.edu/htmls/ana/OneSampleZTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "Proportion Test (Dichotomous)", "url": "http://socr.ucla.edu/htmls/ana/ProportionTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "Principal Component Analysia (PCA)", "url": "http://www.socr.ucla.edu/htmls/ana/PrincipalComponent_Analysis.html", "size": 10370.37037037037},
                          {"name": "Simple Linear Regression", "url": "http://socr.ucla.edu/htmls/ana/SimpleRegression_Analysis.html", "size": 10370.37037037037},
                          {"name": "Survival Analysis", "url": "http://socr.ucla.edu/htmls/ana/Survival_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Independent Sample T-Test (Pooled)", "url": "http://socr.ucla.edu/htmls/ana/TwoIndependentTTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Independent Sample T-Test (Unpooled)", "url": "http://socr.ucla.edu/htmls/ana/TwoIndependentTTestUnpooled_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Independent Sample Wilcoxon Rank Sum Test", "url": "http://socr.ucla.edu/htmls/ana/TwoIndependentSampleWilcoxonRankSum_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Independent Sample Kruskal-Wallis Test", "url": "http://socr.ucla.edu/htmls/ana/TwoIndependentKruskalWallis_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Paired Sample Sign-Test", "url": "http://www.socr.ucla.edu/htmls/ana/TwoPairedSampleSign-Test_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Paired Sample (Wilcoxon) Signed-Rank Test", "url": "http://socr.ucla.edu/htmls/ana/TwoPairedSampleSignedRankTest_Analysis.html", "size": 10370.37037037037},
                          {"name": "Two Paired Sample T-Test", "url": "http://socr.ucla.edu/htmls/ana/TwoPairedSampleTTest_Analysis.html", "size": 10370.37037037037}]},
                      {"name": "Games", "url": "../../gam", "size": 15555.555555555555,"children":
                        [{"name": "Game Activities", "url": "http://socr.umich.edu/html/gam/", "size": 10370.37037037037, "children":
                          [{"name": "Interactive Scatterplot", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Interactive Histogram with Error Graph", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Galton Board Game", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Interactive Histogram", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Monty Hall Game", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Red and Black Game", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Fourier Game", "url": "../../gam", "size": 10370.37037037037},
                            {"name": "Wavelet Game", "url": "../../gam", "size": 10370.37037037037}]},
                          {"name": "Game Applets", "url": "http://socr.umich.edu/html/gam/", "size": 10370.37037037037, "children":
                            [{"name": "(Interactive Scatterplot) Bivariate Game", "url": "http://www.socr.ucla.edu/htmls/game/Bivariate_Game.html", "size": 10370.37037037037},
                              {"name": "Error Game", "url": "http://www.socr.ucla.edu/htmls/game/Error_Game.html", "size": 10370.37037037037},
                              {"name": "Galton-Board Game", "url": "http://www.socr.ucla.edu/htmls/game/GaltonBoard_Game.html", "size": 10370.37037037037},
                              {"name": "Histogram Game", "url": "http://www.socr.ucla.edu/htmls/game/Histogram_Game.html", "size": 10370.37037037037},
                              {"name": "Monty Hall Game", "url": "http://www.socr.ucla.edu/htmls/game/MontyHall_Game.html", "size": 10370.37037037037},
                              {"name": "Red-Black Game", "url": "http://www.socr.ucla.edu/htmls/game/RedBlack_Game.html", "size": 10370.37037037037},
                              {"name": "Fourier Game", "url": "http://www.socr.ucla.edu/htmls/game/Fourier_Game.html", "size": 10370.37037037037},
                              {"name": "Wavelet Game", "url": "http://www.socr.ucla.edu/htmls/game/Wavelet_Game.html", "size": 10370.37037037037}] } ]},
                      {"name": "Charts", "url": "../../cha", "size": 15555.555555555555,"children":
                        [{"name": "Motion Charts", "url": "../../HTML5/MotionChart/", "size": 10370.37037037037},
                          {"name": "AreaChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "AreaChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChart3DDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChart3DDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChart3DDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo4", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo5", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo7", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo8", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BarChartDemo9", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BoxAndWhiskerChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BoxAndWhiskerChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "BubbleChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "CategoryStepChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "CompassDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "CrosshairDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "CrosshairDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "CrosshairDemo4", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "DifferenceChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "DotChart", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "EventFrequencyDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "HistogramChartDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "HistogramChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "HistogramChartDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "HistogramChartDemo4", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "HistogramChartDemo5", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "IndexChart", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LayeredBarChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LayeredBarChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LineChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LineChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LineChartDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LineChartDemo5", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "LineChartDemo6", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "NormalDistributionDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChart3DDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChart3DDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChart3DDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChartDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PieChartDemo4", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PolarChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PowerTransformChart", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PowerTransformHistogramChartDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PowerTransformQQNormalChartDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "PowerTransformScatterChartDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "QQChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "QQChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "QQChartDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "QQData2DataDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "QQNormalPlotDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "RingChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "ScatterChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "SpiderWebChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedAreaChartDemo", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedBarChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedBarChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedBarChartDemo3", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedBarChartDemo4", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedXYAreaChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StackedXYAreaChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StatisticalBarChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StatisticalBarChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StatisticalLineChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "StatisticalLineChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "SymbolAxisDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "WaterfallChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "XYAreaChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "XYAreaChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "XYBarChartDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "XYBarChartDemo2", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "XYStepRendererDemo1", "url": "../../cha", "size": 10370.37037037037},
                          {"name": "YIntervalChartDemo1", "url": "../../cha", "size": 10370.37037037037}]},
                      {"name": "Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 15555.555555555555,"children":
                        [{"name": "Beta Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Exponential Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Fourier Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Gamma Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Mixed Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Normal Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Poisson Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Rice (Rician) Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037},
                          {"name": "Wavelet Fit Modeler", "url": "http://socr.umich.edu/html/mod/", "size": 10370.37037037037}]}]},

                  {"name": "Additional Software Resources", "url": "http://www.socr.ucla.edu/Applets.dir/OnlineResources.html", "size": 23333.333333333332,"children":
                    [{"name": "High-Precision Distribution Calculators", "url": "http://www.socr.ucla.edu/Applets.dir/OnlineResources.html", "size": 15555.555555555555},
                      {"name": "Conceptual Demo Applets", "url": "http://www.socr.ucla.edu/Applets.dir/OnlineResources.html", "size": 15555.555555555555},
                      {"name": "Tables", "url": "http://socr.umich.edu/Applets/index.html#Tables", "size": 15555.555555555555},
                      {"name": "Statistics packages for Statistical Data Analysis", "url": "http://www.socr.ucla.edu/Applets.dir/OnlineResources.html", "size": 15555.555555555555},
                      {"name": "Function and Image-Processing Tools", "url": "http://www.socr.ucla.edu/Applets.dir/OnlineResources.html", "size": 15555.555555555555},
                      {"name": "Other Online Computational Resources", "url": "http://www.socr.ucla.edu/Applets.dir/OnlineResources.html", "size": 15555.555555555555}]},

                  {"name": "Educational Materials", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials", "size": 23333.333333333332,"children":
                    [ {"name": "Courses", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Courses", "size": 15555.555555555555,"children":
                      [ {"name": "Courses, Training Videos, and Webcasts", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Course_and_Training_Videos", "size": 10370.37037037037},
                        {"name": "2007-2008 Courses", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Courses_2007_2008", "size": 10370.37037037037},
                        {"name": "2006-2007 Courses", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Courses_2006_2007", "size": 10370.37037037037},
                        {"name": "2005-2006 Courses", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Courses_2005_2006", "size": 10370.37037037037},
                        {"name": "2001-2005 Courses", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Courses_2001_2004", "size": 10370.37037037037}]},
                      {"name": "SOCR AP Statistics EBook", "url": "http://wiki.stat.ucla.edu/socr/index.php/EBook", "size":  15555.555555555555,"children":
                        [{"name": "1 Preface", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Preface", "size": 4609.053497942387,"children":
                          [{"name": "1.1 Format", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Format", "size": 3072.7023319615914},
                            {"name": "1.2 Learning and Instructional Usage", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Usage", "size": 3072.7023319615914}]},
                          {"name": "2 Chapter I: Introduction to Statistics", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_I:_Introduction_to_Statistics", "size": 4609.053497942387,"children":
                            [{"name": "2.1 The Nature of Data and Variation", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_IntroVar", "size": 3072.7023319615914},
                              {"name": "2.2 Uses and Abuses of Statistics", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_IntroUses", "size": 3072.7023319615914},
                              {"name": "2.3 Design of Experiments", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_IntroDesign", "size": 3072.7023319615914},
                              {"name": "2.4 Statistics with Tools (Calculators and Computers)", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_IntroTools", "size": 3072.7023319615914}]},
                          {"name": "3 Chapter II: Describing, Exploring, and Comparing Data", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_II:_Describing.2C_Exploring.2C_and_Comparing_Data", "size": 4609.053497942387,"children":
                            [{"name": "3.1 Types of Data", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_DataTypes", "size": 3072.7023319615914},
                              {"name": "3.2 Summarizing data with Frequency Tables", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Freq", "size": 3072.7023319615914},
                              {"name": "3.3 Pictures of Data", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Pics", "size": 3072.7023319615914},
                              {"name": "3.4 Measures of Central Tendency", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Center", "size": 3072.7023319615914},
                              {"name": "3.5 Measures of Variation", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Var", "size": 3072.7023319615914},
                              {"name": "3.6 Measures of Shape", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Shape", "size": 3072.7023319615914},
                              {"name": "3.7 Statistics", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Statistics", "size": 3072.7023319615914},
                              {"name": "3.8 Graphs and Exploratory Data Analysis", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_EDA_Plots", "size": 3072.7023319615914}]  },
                          {"name": "4 Chapter III: Probability", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_III:_Probability", "size": 4609.053497942387,"children":
                            [{"name": "4.1 Fundamentals", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Prob_Basics", "size": 3072.7023319615914},
                              {"name": "4.2 Rules for Computing Probabilities", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Prob_Rules", "size": 3072.7023319615914},
                              {"name": "4.3 Probabilities Through Simulations", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Prob_Simul", "size": 3072.7023319615914},
                              {"name": "4.4 Counting", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Prob_Count", "size": 3072.7023319615914}]  },
                          {"name": "5 Chapter IV: Probability Distributions", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_IV:_Probability_Distributions", "size": 4609.053497942387,"children":
                            [{"name": "5.1 Random Variables", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Distrib_RV", "size": 3072.7023319615914},
                              {"name": "5.2 Expectation (Mean) and Variance", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Distrib_MeanVar", "size": 3072.7023319615914},
                              {"name": "5.3 Bernoulli and Binomial Experiments", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Distrib_Binomial", "size": 3072.7023319615914},
                              {"name": "5.4 Geometric, Hypergeometric and Negative Binomial", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Distrib_Dists", "size": 3072.7023319615914},
                              {"name": "5.5 Poisson Distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Distrib_Poisson", "size": 3072.7023319615914}]   },
                          {"name": "6 Chapter V: Normal Probability Distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_V:_Normal_Probability_Distribution.html", "size": 4609.053497942387,"children":
                            [{"name": "6.1 The Standard Normal Distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Normal_Std", "size": 3072.7023319615914},
                              {"name": "6.2 Nonstandard Normal Distribution: Finding Probabilities", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Normal_Prob", "size": 3072.7023319615914},
                              {"name": "6.3 Nonstandard Normal Distribution: Finding Scores (critical values)", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Normal_Critical", "size": 3072.7023319615914}]},
                          {"name": "7 Chapter VI: Relations Between Distributions", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_VI:_Relations_Between_Distributions", "size": 4609.053497942387,"children":
                            [{"name": "7.1 The Central Limit Theorem", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Limits_CLT", "size": 3072.7023319615914},
                              {"name": "7.2 Law of Large Numbers", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Limits_LLN", "size": 3072.7023319615914},
                              {"name": "7.3 Normal Distribution as Approximation to Binomial Distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Limits_Norm2Bin", "size": 3072.7023319615914},
                              {"name": "7.4 Poisson Approximation to Binomial Distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Limits_Poisson2Bin", "size": 3072.7023319615914},
                              {"name": "7.5 Binomial Approximation to HyperGeometric", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Limits_Bin2HyperG", "size": 3072.7023319615914},
                              {"name": "7.6 Normal Approximation to Poisson", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Limits_Norm2Poisson", "size": 3072.7023319615914}]},
                          {"name": "8 Chapter VII: Point and Interval Estimates", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_VII:_Point_and_Interval_Estimates", "size": 4609.053497942387,"children":
                            [{"name": "8.1 Estimating a Population Mean: Large Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Estim_L_Mean", "size": 3072.7023319615914},
                              {"name": "8.2 Estimating a Population Mean: Small Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Estim_S_Mean", "size": 3072.7023319615914},
                              {"name": "8.3 Student's T distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_StudentsT", "size": 3072.7023319615914},
                              {"name": "8.4 Estimating a Population Proportion", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Estim_Proportion", "size": 3072.7023319615914},
                              {"name": "8.5 Estimating a Population Variance", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Estim_Var", "size": 3072.7023319615914}]},
                          {"name": "9 Chapter VIII: Hypothesis Testing", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_VIII:_Hypothesis_Testing", "size": 4609.053497942387,"children":
                            [{"name": "9.1 Fundamentals of Hypothesis Testing", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Hypothesis_Basics", "size": 3072.7023319615914},
                              {"name": "9.2 Testing a Claim about a Mean: Large Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Hypothesis_L_Mean", "size": 3072.7023319615914},
                              {"name": "9.3 Testing a Claim about a Mean: Small Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Hypothesis_S_Mean", "size": 3072.7023319615914},
                              {"name": "9.4 Testing a Claim about a Proportion", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Hypothesis_Proportion", "size": 3072.7023319615914},
                              {"name": "9.5 Testing a Claim about a Standard Deviation or Variance", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Hypothesis_Var", "size": 3072.7023319615914}]},
                          {"name": "10 Chapter IX: Inferences from Two Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_IX:_Inferences_from_Two_Samples", "size": 4609.053497942387,"children":
                            [{"name": "10.1 Inferences about Two Means: Dependent Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Infer_2Means_Dep", "size": 3072.7023319615914},
                              {"name": "10.2 Inferences about Two Means: Independent and Large Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Infer_2Means_Indep", "size": 3072.7023319615914},
                              {"name": "10.3 Comparing Two Variances", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Infer_BiVar", "size": 3072.7023319615914},
                              {"name": "10.4 Inferences about Two Means: Independent and Small Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Infer_2Means_S_Indep", "size": 3072.7023319615914},
                              {"name": "10.5 Inferences about Two Proportions", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Infer_2Proportions", "size": 3072.7023319615914}]},
                          {"name": "11 Chapter X: Correlation and Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_X:_Correlation_and_Regression", "size": 4609.053497942387,"children":
                            [{"name": "11.1 Correlation", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_GLM_Corr", "size": 3072.7023319615914},
                              {"name": "11.2 Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_GLM_Regress", "size": 3072.7023319615914},
                              {"name": "11.3 Variation and Prediction Intervals", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_GLM_Predict", "size": 3072.7023319615914},
                              {"name": "11.4 Multiple Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_GLM_MultLin", "size": 3072.7023319615914}]},
                          {"name": "12 Chapter XI: Analysis of Variance (ANOVA)", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XI:_Analysis_of_Variance_.28ANOVA.29", "size": 4609.053497942387,"children":
                            [{"name": "12.1 One-Way ANOVA", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_ANOVA_1Way", "size": 3072.7023319615914},
                              {"name": "12.2 Two-Way ANOVA", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_ANOVA_2Way", "size": 3072.7023319615914}]},
                          {"name": "13 Chapter XII: Non-Parametric Inference", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XII:_Non-Parametric_Inference", "size": 4609.053497942387,"children":
                            [{"name": "13.1 Differences of Means of Two Paired Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_2MeansPair", "size": 3072.7023319615914},
                              {"name": "13.2 Differences of Means of Two Independent Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_2MeansIndep", "size": 3072.7023319615914},
                              {"name": "13.3 Differences of Medians of Two Paired Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_2MedianPair", "size": 3072.7023319615914},
                              {"name": "13.4 Differences of Medians of Two Independent Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_2MedianIndep", "size": 3072.7023319615914},
                              {"name": "13.5 Differences of Proportions of Two Independent Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_2PropIndep", "size": 3072.7023319615914},
                              {"name": "13.6 Differences of Means of Several Independent Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_ANOVA", "size": 3072.7023319615914},
                              {"name": "13.7 Differences of Variances of Two Independent Samples", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_NonParam_VarIndep", "size": 3072.7023319615914}]},
                          {"name": "14 Chapter XIII: Multinomial Experiments and Contingency Tables", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XIII:_Multinomial_Experiments_and_Contingency_Tables", "size": 4609.053497942387,"children":
                            [{"name": "14.1 Multinomial Experiments: Goodness-of-Fit", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Contingency_Fit", "size": 3072.7023319615914},
                              {"name": "14.2 Contingency Tables: Independence and Homogeneity", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Contingency_Indep", "size": 3072.7023319615914}]},
                          {"name": "15 Chapter XIV: Statistical Process Control", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XIV:_Statistical_Process_Control", "size": 4609.053497942387,"children":
                            [{"name": "15.1 Control Charts for Variation and Mean", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Control_MeanVar", "size": 3072.7023319615914},
                              {"name": "15.2 Control Charts for Attributes", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_Control_Attrib", "size": 3072.7023319615914}]},
                          {"name": "16 Chapter XV: Survival/Failure Analysis", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XV:_Survival.2FFailure_Analysis", "size": 4609.053497942387},
                          {"name": "17 Chapter XVI: Multivariate Statistical Analyses", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XVI:_Multivariate_Statistical_Analyses", "size": 4609.053497942387,"children":
                            [{"name": "17.1 Multivariate Analysis of Variance", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_MultiVar_ANOVA", "size": 3072.7023319615914},
                              {"name": "17.2 Multiple Linear Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_MultiVar_LinRegression", "size": 3072.7023319615914},
                              {"name": "17.3 Logistic Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_MultiVar_Logistic", "size": 3072.7023319615914},
                              {"name": "17.4 Log-Linear Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_MultiVar_LogLinear", "size": 3072.7023319615914},
                              {"name": "17.5 Multivariate Analysis of Covariance", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007_MultiVar_ANCOVA", "size": 3072.7023319615914}]},
                          {"name": "18 Chapter XVII: Time Series Analysis", "url": "http://wiki.stat.ucla.edu/socr/index.php/AP_Statistics_Curriculum_2007#Chapter_XVII:_Time_Series_Analysis", "size": 4609.053497942387} ]},
                      {"name": "Surveys", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Surveys", "size": 15555.555555555555,"children": [{"name": "Survey Fall 2005 Stat 100A Christou", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Surveys_Fall2005Christou", "size": 10370.37037037037},{"name": "Survey Fall 2005 Stat 100A Sanchez", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Surveys_Fall2005Sanchez", "size": 10370.37037037037},{"name": "Moodle Surveys", "url": "http://moodle.stat.ucla.edu/course/", "size": 10370.37037037037}]},
                      {"name": "Datasets", "url": "http://wiki.socr.umich.edu/index.php/SOCR_Data", "size": 15555.555555555555},
                      {"name": "Activities", "url": "http://wiki.socr.umich.edu/index.php/SOCR_EduMaterials", "size": 15555.555555555555, "children":
                        [{"name": "Distribution Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_DistributionsActivities", "size": 15555.555555555555,"children": [{"name": "CLT", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GeneralCentralLimitTheorem", "size": 10370.37037037037},{"name": "Poisson", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Poisson_Distribution.html", "size": 10370.37037037037},{"name": "Exponential", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Exponential_Distribution.html", "size": 10370.37037037037},{"name": "Normal", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Normal_Distribution.html", "size": 10370.37037037037},{"name": "Binomial, Geometric, Hypergeometric Distributions", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Binomial_Distributions", "size": 10370.37037037037},{"name": "Continuous Distributions", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Continuous_Distributions", "size": 10370.37037037037},{"name": "Negative Binomial", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_NegativeBinomial_Distributions", "size": 10370.37037037037},{"name": "Relationships and Approximations Among Distributions", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Explore_Distributions", "size": 10370.37037037037}]},
                          {"name": "Experiments Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_ExperimentsActivities", "size": 15555.555555555555,"children": [{"name": "Ballot Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BallotExperiment", "size": 10370.37037037037},{"name": "Ball And Urn Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BallAndRunExperiment", "size": 10370.37037037037},{"name": "Bertrand Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BertrandExperiment", "size": 10370.37037037037},{"name": "Beta Coin Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BetaCoinExperiment", "size": 10370.37037037037},{"name": "Beta Estimate Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BetaEstimateExperiment", "size": 10370.37037037037},{"name": "Binomial Coin Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BinomialCoinExperiment", "size": 10370.37037037037},{"name": "Binomial Timeline Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BinomialTimelineExperiment", "size": 10370.37037037037},{"name": "Birthday Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BirthdayExperiment", "size": 10370.37037037037},{"name": "Bivariate Normal Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BivariateNormalExperiment", "size": 10370.37037037037},{"name": "Bivariate Uniform Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BivariteUniformExperiment", "size": 10370.37037037037},{"name": "Buffon Coin Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BuffonCoinExperiment", "size": 10370.37037037037},{"name": "Buffon Needle Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_BuffonNeedleExperiment", "size": 10370.37037037037},{"name": "Card Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CardExperiment", "size": 10370.37037037037},{"name": "Chi Square Dice Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_ChiSquareDiceExperiment", "size": 10370.37037037037},{"name": "Chuck A Luck Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_ChuckALuckExperiment", "size": 10370.37037037037},{"name": "Coin Die Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CoinDieExperiment", "size": 10370.37037037037},{"name": "Coin Sample Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CoinSampleExperiment", "size": 10370.37037037037},{"name": "Confidence Interval Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CoinfidenceIntervalExperiment", "size": 10370.37037037037},{"name": "Coupon Collector Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CouponCollectorExperiment", "size": 10370.37037037037},{"name": "Craps Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CrapsExperiment", "size": 10370.37037037037},{"name": "Dice Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_DiceExperiment", "size": 10370.37037037037},{"name": "Dice Sample Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_DiceSampleExperiment", "size": 10370.37037037037},{"name": "Die Coin Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_DieCoinExperiment", "size": 10370.37037037037},{"name": "Exponential Car-Time Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_ExpCarTimeExperiment", "size": 10370.37037037037},{"name": "Finite Order Statistic Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_FiniteOrderStatisticExperiment", "size": 10370.37037037037},{"name": "Galton Board Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GaltonBoardExperiment", "size": 10370.37037037037},{"name": "Gamma Estimate Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GammaEstimateExperiment", "size": 10370.37037037037},{"name": "Gamma Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GammaExperiment", "size": 10370.37037037037},{"name": "Law Of Large Numbers Experiment", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_LawOfLargeNumbersExperiment", "size": 10370.37037037037},{"name": "SOCR Cards and Coins Sampling Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CardsCoinsSampling", "size": 10370.37037037037},{"name": "Central Limit Theorem", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CentralLimitTheorem", "size": 10370.37037037037},{"name": "Die Coin Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_DieCoin", "size": 10370.37037037037},{"name": "Confidence Intervals", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_ConfIntervals", "size": 10370.37037037037},{"name": "Dice Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_DiceExperiment", "size": 10370.37037037037},{"name": "General Central Limit Theorem", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GeneralCentralLimitTheorem", "size": 10370.37037037037},{"name": "Joint Distributons", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_JointDistributions", "size": 10370.37037037037},{"name": "Law of Large Numbers", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_LawOfLargeNumbers", "size": 10370.37037037037},{"name": "Matching experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Matching_Juana_oct10-06_version1", "size": 10370.37037037037},{"name": "Monty Hall Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_MontyHall", "size": 10370.37037037037},{"name": "Craps Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Craps", "size": 10370.37037037037}]},
                          {"name": "Analysis Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysesActivities", "size": 15555.555555555555,"children": [{"name": "One-Way Analysis of Variance (ANOVA)", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_ANOVA_1", "size": 10370.37037037037},{"name": "Two-Way Analysis of Variance (ANOVA)", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_ANOVA_2", "size": 10370.37037037037},{"name": "Simple Linear Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_SLR", "size": 10370.37037037037},{"name": "Multiple Linear Regression", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_MLR", "size": 10370.37037037037},{"name": "One-Smaple T-Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_OneT", "size": 10370.37037037037},{"name": "Two Independent Sample (Pooled) T-Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_TwoIndepT", "size": 10370.37037037037},{"name": "Two Independent Sample (Unpooled) T-Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_TwoIndepTU", "size": 10370.37037037037},{"name": "Two Independent Sample Wilcoxon Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Wilcoxon", "size": 10370.37037037037},{"name": "Kruskal-Wallis Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_KruskalWallis", "size": 10370.37037037037},{"name": "Friedman's Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Friedman", "size": 10370.37037037037},{"name": "Fisher's Exact Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Fisher_Exact", "size": 10370.37037037037},{"name": "Two Paired Sample T-Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_TwoPairedT", "size": 10370.37037037037},{"name": "Two Paired Smaple Sign-Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_TwoPairedSign", "size": 10370.37037037037},{"name": "Two Paired Smaple Signed-Rank Test", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_TwoPairedRank", "size": 10370.37037037037},{"name": "Chi-Square Test for Contingency Tables", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Chi_Contingency", "size": 10370.37037037037},{"name": "Chi-Square Test for Goodness of Fit", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Chi_Goodness", "size": 10370.37037037037},{"name": "Proportion Test for Dichotomous Data", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Proportion_Test", "size": 10370.37037037037},{"name": "Survival Analysis", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_Survival", "size": 10370.37037037037},{"name": "Power Analysis for Normal Distribution", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_AnalysisActivities_NormalPower", "size": 10370.37037037037}]},
                          {"name": "Games Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_GamesActivities", "size": 15555.555555555555,"children": [{"name": "Wavelet Game", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_GamesActivitiesWavelets", "size": 10370.37037037037},{"name": "Fourier Game", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_GamesActivitiesFourier", "size": 10370.37037037037}]},
                          {"name": "Modeler Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_ModelerActivities", "size": 15555.555555555555,"children": [{"name": "Mixture Model Fitting using EM estimation", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_ModelerActivities_MixtureModel_1", "size": 10370.37037037037},{"name": "Random Number Generator (RNG)", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_RNG", "size": 10370.37037037037}]},
                          {"name": "Charts Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_ChartsActivities", "size": 15555.555555555555,"children": [{"name": "Cards and Coins Sampling Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CardsCoinsSampling", "size": 10370.37037037037},{"name": "Power-Transform Family Graphs", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_PowerTransformFamily_Graphs", "size": 10370.37037037037},{"name": " 2D Point Segmentation using SOCR Graphs, EM and Mixture Modeling", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_2D_PointSegmentation_EM_Mixture", "size": 10370.37037037037}]},
                          {"name": "General Activities", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities", "size": 15555.555555555555,"children": [{"name": "SOCR Birthday Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Birthday", "size": 10370.37037037037},{"name": "SOCR Bivariate Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Bivariate", "size": 10370.37037037037},{"name": "SOCR Cards and Coins Sampling Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CardsCoinsSampling", "size": 10370.37037037037},{"name": "SOCR SOCR Central Limit Theorem Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_CLT", "size": 10370.37037037037},{"name": "SOCR Confidence Intervals Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_ConfidenceIntervals", "size": 10370.37037037037},{"name": "SOCR Distributions Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Distributions", "size": 10370.37037037037},{"name": "SOCR General Central Limit Theorem", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GeneralCentralLimitTheorem", "size": 10370.37037037037},{"name": "SOCR General Central Limit Theorem (2)", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_GeneralCentralLimitTheorem2", "size": 10370.37037037037},{"name": "SOCR Matching Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_matching", "size": 10370.37037037037},{"name": "SOCR Random Number Generation", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_RNG", "size": 10370.37037037037},{"name": "SOCR Triangles Experiment Activity", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Activities_Triangles", "size": 10370.37037037037}]}]},
                      {"name": "Educational Plans", "url": "http://wiki.socr.umich.edu/index.php/SOCR_EduMaterials", "size": 15555.555555555555, "children":
                        [ {"name": "Surveys", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Surveys", "size": 10370.37037037037,"children": [{"name": "Survey Fall 2005 Stat 100A Christou", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Surveys_Fall2005Christou", "size": 10370.37037037037},{"name": "Survey Fall 2005 Stat 100A Sanchez", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_EduMaterials_Surveys_Fall2005Sanchez", "size": 10370.37037037037},{"name": "Moodle Surveys", "url": "http://moodle.stat.ucla.edu/course/", "size": 10370.37037037037}]},
                          {"name": "Instructor Plans", "url": "http://www.socr.ucla.edu/docs/SOCR_InstructorPlan.html", "size": 10370.37037037037},
                          {"name": "Evaluations", "url": "http://wiki.socr.umich.edu/index.php/SOCR_EduMaterials_Evaluations", "size": 10370.37037037037},
                          {"name": "K-12 Educational Materials", "url": "http://wiki.socr.umich.edu/index.php/K12_Education", "size": 10370.37037037037},
                          {"name": "AP Stats", "url": "http://socr.ucla.edu/APStats/", "size": 10370.37037037037}
                        ]
                      }]},

                  {"name": "SOCR Wiki", "url": "http://wiki.stat.ucla.edu/socr/index.php/Main_Page", "size": 23333.333333333332,"children":
                    [{"name": "SOCR Docs", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Docs", "size": 15555.555555555555,"children":
                      [{"name": "Developer Documentation", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Developer_Documentation", "size": 10370.37037037037},
                        {"name": "Usage Documentation", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Usage_Documentaiton", "size": 10370.37037037037},
                        {"name": "Function Documentation", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Function_Documentaiton", "size": 10370.37037037037},
                        {"name": "Java API Documentation", "url": "http://socr.ucla.edu/docs/SOCR_Documentation.html", "size": 10370.37037037037},
                        {"name": "SOCR 3D Logo", "url": "http://wiki.stat.ucla.edu/socr/uploads/2/20/SOCR_Logos_3D_PDF.pdf", "size": 10370.37037037037}]},

                      {"name": "SOCR Blog", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_UserFeedback", "size": 15555.555555555555},

                      {"name": "Community Portal", "url": "http://wiki.stat.ucla.edu/socr/index.php/Socr:Community_Portal", "size": 15555.555555555555,"children":
                        [{"name": "Event-Related Community Portal", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_CommunityPortal_Events", "size": 10370.37037037037,"children":
                          [{"name": "August 2007 SOCR/CAUSE Workshop", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Events_Aug2007", "size": 6913.580246913581},
                            {"name": "August 2009 SOCR Continuing Education Workshop", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Events_Aug2009", "size": 6913.580246913581}]  },
                          {"name": "General Community Portal", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_CommunityPortal_General", "size": 10370.37037037037}   ]}]
                  },


                  {"name": "About SOCR", "url": "../../SOCR_About.html", "size": 23333.333333333332,"children":
                    [{"name": "News & Notice", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News", "size": 15555.555555555555, "children":
                      [{"name": "2014 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2014", "size": 6913.580246913581},{"name": "2013 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2013", "size": 6913.580246913581},{"name": "2012 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2012", "size": 6913.580246913581},{"name": "2011 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2011", "size": 6913.580246913581},{"name": "2010 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2010", "size": 6913.580246913581},{"name": "2009 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2009", "size": 6913.580246913581},{"name": "2008 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2008", "size": 6913.580246913581},{"name": "2007 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2007", "size": 6913.580246913581},{"name": "2006 News", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_News#2006", "size": 6913.580246913581}]},
                      {"name": "Events", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Events", "size": 10370.37037037037,"children":
                        [{"name": "SOCR 2009 Training Workshop", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Events_Aug2009", "size": 6913.580246913581},{"name": "SOCR/CAUSE 2007 Workshop", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Events_Aug2007", "size": 6913.580246913581},{"name": "USCOTS 2007 Workshop", "url": "http://wiki.stat.ucla.edu/socr/index.php/USCOTS_2007_Program", "size": 6913.580246913581},{"name": "Past, Current and Future SOCR Presentations", "url": "http://www.socr.ucla.edu/htmls/SOCR_Presentations.html", "size": 6913.580246913581},{"name": "SOCR Sponsored Events", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Events_SponsoredEvents", "size": 6913.580246913581}]},
                      {"name": "Announcements", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Announcements", "size": 10370.37037037037},
                      {"name": "SOCR in the Media", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Media", "size": 10370.37037037037},
                      {"name": "SOCR Projects", "url": "http://wiki.stat.ucla.edu/socr/index.php/Available_SOCR_Development_Projects", "size": 10370.37037037037,"children":
                        [{"name": "Available SOCR Collaborative Development Projects", "url": "http://wiki.stat.ucla.edu/socr/index.php/Available_SOCR_Development_Projects", "size": 6913.580246913581},
                          {"name": "SOCR Group Projects", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Group_Projects", "size": 6913.580246913581},
                          {"name": "SOCR Project Proposal Submission Guidelines", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_ProposalSubmissionGuidelines", "size": 6913.580246913581}]},
                      {"name": "Team", "url": "../../SOCR_Team.html", "size": 15555.555555555555},
                      {"name": "Contact", "url": "../../SOCR_Contact.html", "size": 15555.555555555555},
                      {"name": "Geo-Map", "url": "../../SOCR_UserGoogleMap.html", "size": 15555.555555555555},
                      {"name": "Presentations", "url": "../../SOCR_Presentations.html", "size": 15555.555555555555},
                      {"name": "Publicationss", "url": "../../SOCR_Presentations.html", "size": 15555.555555555555},
                      {"name": "SOCR Brochure", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555},

                      {"name": "Collaborators and Partners", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Partners", "size": 15555.555555555555},
                      {"name": "Funding", "url": "../../SOCR_Funding.html", "size": 15555.555555555555},
                      {"name": "Donations", "url": "../../SOCR_Funding.html", "size": 15555.555555555555},
                      {"name": "References", "url": "../../SOCR_References.html", "size": 15555.555555555555},
                      {"name": "Recognitions", "url": "../../SOCR_Recognitions.html", "size": 15555.555555555555},
                      {"name": "Acknowledgments", "url": "../../SOCR_Acknowledgements.html", "size": 15555.555555555555},
                      {"name": "Citing & Licences", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555},
                      {"name": "Feedback & Survey", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555},

                      {"name": "Forum", "url": "http://forums.stat.ucla.edu/socr", "size": 15555.555555555555},
                      {"name": "SOCR Servers", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Servers", "size": 15555.555555555555,"children":
                        [{"name": "SOCR Main Servers", "url": "../../SOCR.html", "size": 10370.37037037037, "children":[
                          {"name": "Primary Server", "url": "../../SOCR.html", "size": 6913.580246913581},
                          {"name": "Wiki Server", "url": "http://wiki.stat.ucla.edu/socr", "size": 6913.580246913581},
                          {"name": "Forum Server", "url": "http://forums.stat.ucla.edu/socr", "size": 6913.580246913581},
                          {"name": "Source Code (GoogleCode)", "url": "http://socr.googlecode.com/", "size": 6913.580246913581},
                          {"name": "Source Code (GitHub)", "url": "https://github.com/SOCRedu/", "size": 6913.580246913581},
                          {"name": "Source Code (new GitHub)", "url": "https://github.com/SOCR", "size": 6913.580246913581},
                          {"name": "University of California eScholarship", "url": "http://escholarship.org/uc/socr", "size": 6913.580246913581},
                          {"name": "SOCR eScholar Pubs", "url": "http://escholarship.org/uc/stats/unit/socr.html", "size": 6913.580246913581}
                        ]},

                          {"name": "SOCR User Counting Servers", "url": "../../SOCR.html", "size": 10370.37037037037, "children":[
                            {"name": "Counter's SOCR Server Users", "url": "http://counter.digits.net/?counter=SOCR", "size": 6913.580246913581},
                            {"name": "MediaWiki SOCR Michigan Server Users", "url": "http://wiki.stat.ucla.edu/socr", "size": 6913.580246913581},
                            {"name": "MediaWiki SOCR UCLA Server Users", "url": "http://forums.stat.ucla.edu/socr", "size": 6913.580246913581},
                            {"name": "Source Code (GoogleCode)", "url": "http://socr.googlecode.com/", "size": 6913.580246913581},
                            {"name": "University of California eScholarship", "url": "http://escholarship.org/uc/stats/unit/socr_rw.html", "size": 6913.580246913581},
                            {"name": "SOCR eScholar Pubs", "url": "http://escholarship.org/uc/stats/author/edu/ucla/stat/dinov/dinov_ivo_d.html", "size": 6913.580246913581},
                            {"name": "StatCounter's SOCR Users", "url": "http://statcounter.com/p5714596/visitor_map/?&account_id=2993174&login_id=3&code=c09a63d61e8e069f31392a36ffcaeec4&guest_login=1&project_id=5714596&perpage=300", "size": 6913.580246913581}
                          ]},

                          {"name": "SOCR Mirrors (known public mirrors only)", "url": "http://wiki.stat.ucla.edu/socr/index.php/SOCR_Servers", "size": 10370.37037037037,"children":
                            [{"name": "PsyResearch", "url": "http://psyresearch.org/statistics/socr/", "size": 6913.580246913581},
                              {"name": "ASA Amstat", "url": "http://www.amstat.org/publications/jse/socr/", "size": 6913.580246913581}]}]},
                      {"name": "Documentation", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555},
                      {"name": "Translation", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555},
                      {"name": "SOCR Resource Navigator", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555},
                      {"name": "Carousel Viewer", "url": "http://http://socr.ucla.edu/docs/SOCR_Brochure_Integrated2Page_2008.pdf", "size": 15555.555555555555}
                    ]
                  }]
              }

      xScale = d3.scale.linear().range([0, width])
      yScale = d3.scale.linear().range([0, height])
      color = d3.scale.category10()
      headerHeight = 20
      headerColor = '#555555'
      transitionDuration = 500

      treemap = d3.layout.treemap().size([width,height]).sticky(true).value((d) -> d.size)

      chart = svg.append('g')

      # Helper functions
      size = (d) ->
        d.size

      count = (d) ->
        1

      getRGBComponents = (color) ->
        r = color.substring(1, 3)
        g = color.substring(3, 5)
        b = color.substring(5, 7)
        {
          R: parseInt(r, 16)
          G: parseInt(g, 16)
          B: parseInt(b, 16)
        }
        return

      idealTextColor = (bgColor) ->
        nThreshold = 105
        components = getRGBComponents(bgColor)
        bgDelta = components.R * 0.299 + components.G * 0.587 + components.B * 0.114
        if 255 - bgDelta < nThreshold then '#000000' else '#ffffff'
        return


      zoom = (d) ->
        @treemap.padding([headerHeight / (height / d.dy), 0, 0, 0])
        .nodes(d)

        # moving the next two lines above treemap layout messes up padding of zoom result
        kx = width / d.dx
        ky = height / d.dy
        level = d
        xScale.domain([d.x, d.x + d.dx])
        yScale.domain([d.y, d.y + d.dy])

        if node != level
          chart.selectAll('.cell.child.label').style('display', 'none')

        zoomTransition = chart.selectAll('g.cell').transition().duration(transitionDuration)
        .attr('transform', (d) -> 'translate(' + xScale(d.x) + ',' + yScale(d.y) + ')')
        .each('start', () ->
          d3.select(@).select('label').style('display', 'none')
        ).each('end', (d, i) ->
          if !i and level != self.root
            chart.selectAll('.cell.child').filter((d) ->
              d.parent == self.node # only get the children for selected group
            ).select('.label')
            .style('dispaly', '')
            .style('fill', (d) -> idealTextColor(color(d.parent.name)))
        )

        # Update the width/height of the rects
        zoomTransition.select('.clip')
        .attr('width', (d) -> Math.max(0.01, (kx * d.dx)))
        .attr('height', (d) -> if d.children then headerHeight else Math.max(0.01, (kx * d.dy)))

        zoomTransition.select('.label')
        .attr('width', (d) -> Math.max(0.01, kx * d.dx))
        .attr('height', (d) -> if d.children then headerHeight else Math.max(0.01, ky * d.dy))
        .text((d) -> d.name)

        zoomTransition.select('.child .label')
        .attr('x', (d) -> kx * d.dx / 2)
        .attr('y', (d) -> ky * d.dy / 2)

        zoomTransition.select('rect')
        .attr('width', (d) -> Math.max(0.01, (kx * d.dx)))
        .attr('height', (d) -> if d.children then headerHeight else Math.max(0.01, (ky * d.dy)))
        .style('fill', (d) -> if d.children then headerColor else color(d.parent.name))

        node = d

        if d3.event
          d3.event.stopPropagation()
        return


      root = data
      node = root
      nodes = treemap.nodes(root)
      children = nodes.filter((d) -> !d.children)
      parents = nodes.filter((d) -> d.children)

      ###
      # Create parent cells
      parentCells = chart.selectAll('g.cell.parent').data(parents, (d) -> 'p-' + d.name)
      parentEnterTransition = parentCells.enter()
      .append('g')
      .attr('class', 'cell parent')
      .attr('transform', (d) -> 'translate(' + d.x + ',' + d.y + ')')
      .on('click', (d) -> zoom(d))
      .append('svg')
      .attr('class', 'clip')
      .attr('width', (d) -> Math.max(0.01, d.dx - 1))
      .attr('height', headerHeight)
      parentEnterTransition.append('rect')
      .attr('width', (d) -> Math.max(0.01, d.dx - 1))
      .attr('height', headerHeight)
      .style('fill', headerColor)
      parentEnterTransition.append('text')
      .attr('class', 'label')
      .attr("transform", () -> 'translate(3,13)')
      .attr("width", (d) -> Math.max(0.01, d.dx - 1))
      .attr("height", headerHeight)
      .text((d) -> d.name)
      # Update transition
      parentUpdateTransition = parentCells.transition().duration(transitionDuration)
      parentUpdateTransition.select('.cell')
      .attr('transform', (d) -> 'translate(' + d.dx + ',' + d.y + ')')
      parentUpdateTransition.select('rect')
      .attr('width', (d) -> Math.max(0.01, d.dx - 1))
      .attr('height', headerHeight)
      .style('fill', headerColor)
      parentUpdateTransition.select('.label')
      .attr('transform', 'translate(3, 13)')
      .attr('width', (d) -> Math.max(0.01, d.dx - 1))
      .attr('height', headerHeight)
      .text((d) -> d.name)
      # Remove transition
      parentCells.exit().remove()
      ###
      # Create children cells
      childrenCells = chart.selectAll('g.cell.child').data(children, (d) -> 'c-' + d.name)

      # Enter transition
      childEnterTransition = childrenCells.enter()
      .append('g')
      .attr('class', 'cell child')
      .attr('transform', (d) -> 'translate(' + d.x + ',' + d.y + ')')
      #.on('click', (d) -> zoom( if node == d.parent then root else d.parent))
      .append('svg')
      .attr('class', 'clip')
      .attr('width', (d) -> Math.max(0.01, d.dx - 1))
      .attr('height', (d) -> Math.max(0.01, d.dy - 1))
      #.append('a').attr('xlink:href', (d) -> console.log d.url)
      .on('click', (d) ->
        console.log d.url
        window.open(d.url)
      )
      .on('mouseover', () ->
        d3.select(@).append('title')
        .text((d) ->
          'Parent: ' + d.parent.name + '\n' +
            'Name: ' + d.name + '\n' +
            'Depth: ' + d.depth
        )
        d3.select(@).select('rect')
        .attr('stroke', 'black')
        .attr('stroke-width', 5)

      )
      .on('mouseout', () ->
        d3.select(@).select('rect')
        .attr('stroke', 'white')
        .attr('stroke-width', 0)
        d3.select(@).select('title').remove()
      )


      childEnterTransition.append('rect')
      .classed('background', true)
      .style('fill', (d) -> color(d.parent.name))

      childEnterTransition.append('text')
      .attr('class', 'label')
      .attr('x', (d) -> d.dx / 2)
      .attr('y', (d) -> d.dy / 2)
      .attr('dy', '0.35em')
      .text((d) -> d.name)

      # Do not show children's label
      #childEnterTransition.selectAll('.foreignObject .labelbody .label').style('display', 'none')

      # Update transition
      childUpdateTransition = childrenCells.transition().duration(transitionDuration)

      childUpdateTransition.select('.cell')
      .attr('transform', (d) -> 'translate(' + d.x + ',' + d.y + ')')

      childUpdateTransition.select('rect')
      .attr('width', (d) -> Math.max(0.01, d.dx))
      .attr('height', (d) -> d.dy)
      .style('fill', (d) -> color(d.parent.name))

      childUpdateTransition.select('.label')
      .attr('x', (d) -> d.dx / 2)
      .attr('y', (d) -> d.dy / 2)
      .attr('dy', '0.35em')
      .style('display', 'none')
      .text((d) -> d.name)


      # Exit transition
      childrenCells.exit().remove()

      ###
      d3.select('select').on('change', () ->
        console.log('select zoom(node)')
        treemap.value(if @value == 'size'then size else count )
        .nodes(root)
        zoom(node)
      )
      ###
      #zoom(node)


    drawTreemap: _drawTreemap
]


.directive 'd3Charts', [
  'scatterPlot',
  'histogram',
  'pie',
  'bubble',
  'bar',
  'streamGraph',
  'area',
  'treemap',
  'line'
  (scatterPlot,histogram,pie,bubble,bar,streamGraph, area, treemap,line) ->
    restrict: 'E'
    template: "<div class='graph-container' style='height: 600px'></div>"
    link: (scope, elem, attr) ->
      margin = {top: 10, right: 40, bottom: 50, left:80}
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
              histogram.drawHist(_graph,data,container,gdata,width,height,ranges)
            when 'Pie Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              pie.drawPie(data,width,height,_graph)
            when 'Scatter Plot'
              scatterPlot.drawScatterPlot(data,ranges,width,height,_graph,container,gdata)
            when 'Stream Graph'
              streamGraph.streamGraph2(data,ranges,width,height,_graph)
            when 'Area Chart'
              area.drawArea(height,width,_graph, data, gdata)
            when 'Treemap'
              treemap.drawTreemap(svg, width, height, margin)
            when 'Line Chart'
              line.lineChart(data,ranges,width,height,_graph, gdata)
]
