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
      data =  {
        "name": "flare",
        "children": [
          {
            "name": "analytics",
            "children": [
              {
                "name": "cluster",
                "children": [
                  {"name": "AgglomerativeCluster", "size": 3938},
                  {"name": "CommunityStructure", "size": 3812},
                  {"name": "HierarchicalCluster", "size": 6714},
                  {"name": "MergeEdge", "size": 743}
                ]
              },
              {
                "name": "graph",
                "children": [
                  {"name": "BetweennessCentrality", "size": 3534},
                  {"name": "LinkDistance", "size": 5731},
                  {"name": "MaxFlowMinCut", "size": 7840},
                  {"name": "ShortestPaths", "size": 5914},
                  {"name": "SpanningTree", "size": 3416}
                ]
              },
              {
                "name": "optimization",
                "children": [
                  {"name": "AspectRatioBanker", "size": 7074}
                ]
              }
            ]
          },
          {
            "name": "animate",
            "children": [
              {"name": "Easing", "size": 17010},
              {"name": "FunctionSequence", "size": 5842},
              {
                "name": "interpolate",
                "children": [
                  {"name": "ArrayInterpolator", "size": 1983},
                  {"name": "ColorInterpolator", "size": 2047},
                  {"name": "DateInterpolator", "size": 1375},
                  {"name": "Interpolator", "size": 8746},
                  {"name": "MatrixInterpolator", "size": 2202},
                  {"name": "NumberInterpolator", "size": 1382},
                  {"name": "ObjectInterpolator", "size": 1629},
                  {"name": "PointInterpolator", "size": 1675},
                  {"name": "RectangleInterpolator", "size": 2042}
                ]
              },
              {"name": "ISchedulable", "size": 1041},
              {"name": "Parallel", "size": 5176},
              {"name": "Pause", "size": 449},
              {"name": "Scheduler", "size": 5593},
              {"name": "Sequence", "size": 5534},
              {"name": "Transition", "size": 9201},
              {"name": "Transitioner", "size": 19975},
              {"name": "TransitionEvent", "size": 1116},
              {"name": "Tween", "size": 6006}
            ]
          },
          {
            "name": "data",
            "children": [
              {
                "name": "converters",
                "children": [
                  {"name": "Converters", "size": 721},
                  {"name": "DelimitedTextConverter", "size": 4294},
                  {"name": "GraphMLConverter", "size": 9800},
                  {"name": "IDataConverter", "size": 1314},
                  {"name": "JSONConverter", "size": 2220}
                ]
              },
              {"name": "DataField", "size": 1759},
              {"name": "DataSchema", "size": 2165},
              {"name": "DataSet", "size": 586},
              {"name": "DataSource", "size": 3331},
              {"name": "DataTable", "size": 772},
              {"name": "DataUtil", "size": 3322}
            ]
          },
          {
            "name": "display",
            "children": [
              {"name": "DirtySprite", "size": 8833},
              {"name": "LineSprite", "size": 1732},
              {"name": "RectSprite", "size": 3623},
              {"name": "TextSprite", "size": 10066}
            ]
          },
          {
            "name": "flex",
            "children": [
              {"name": "FlareVis", "size": 4116}
            ]
          },
          {
            "name": "physics",
            "children": [
              {"name": "DragForce", "size": 1082},
              {"name": "GravityForce", "size": 1336},
              {"name": "IForce", "size": 319},
              {"name": "NBodyForce", "size": 10498},
              {"name": "Particle", "size": 2822},
              {"name": "Simulation", "size": 9983},
              {"name": "Spring", "size": 2213},
              {"name": "SpringForce", "size": 1681}
            ]
          },
          {
            "name": "query",
            "children": [
              {"name": "AggregateExpression", "size": 1616},
              {"name": "And", "size": 1027},
              {"name": "Arithmetic", "size": 3891},
              {"name": "Average", "size": 891},
              {"name": "BinaryExpression", "size": 2893},
              {"name": "Comparison", "size": 5103},
              {"name": "CompositeExpression", "size": 3677},
              {"name": "Count", "size": 781},
              {"name": "DateUtil", "size": 4141},
              {"name": "Distinct", "size": 933},
              {"name": "Expression", "size": 5130},
              {"name": "ExpressionIterator", "size": 3617},
              {"name": "Fn", "size": 3240},
              {"name": "If", "size": 2732},
              {"name": "IsA", "size": 2039},
              {"name": "Literal", "size": 1214},
              {"name": "Match", "size": 3748},
              {"name": "Maximum", "size": 843},
              {
                "name": "methods",
                "children": [
                  {"name": "add", "size": 593},
                  {"name": "and", "size": 330},
                  {"name": "average", "size": 287},
                  {"name": "count", "size": 277},
                  {"name": "distinct", "size": 292},
                  {"name": "div", "size": 595},
                  {"name": "eq", "size": 594},
                  {"name": "fn", "size": 460},
                  {"name": "gt", "size": 603},
                  {"name": "gte", "size": 625},
                  {"name": "iff", "size": 748},
                  {"name": "isa", "size": 461},
                  {"name": "lt", "size": 597},
                  {"name": "lte", "size": 619},
                  {"name": "max", "size": 283},
                  {"name": "min", "size": 283},
                  {"name": "mod", "size": 591},
                  {"name": "mul", "size": 603},
                  {"name": "neq", "size": 599},
                  {"name": "not", "size": 386},
                  {"name": "or", "size": 323},
                  {"name": "orderby", "size": 307},
                  {"name": "range", "size": 772},
                  {"name": "select", "size": 296},
                  {"name": "stddev", "size": 363},
                  {"name": "sub", "size": 600},
                  {"name": "sum", "size": 280},
                  {"name": "update", "size": 307},
                  {"name": "variance", "size": 335},
                  {"name": "where", "size": 299},
                  {"name": "xor", "size": 354},
                  {"name": "_", "size": 264}
                ]
              },
              {"name": "Minimum", "size": 843},
              {"name": "Not", "size": 1554},
              {"name": "Or", "size": 970},
              {"name": "Query", "size": 13896},
              {"name": "Range", "size": 1594},
              {"name": "StringUtil", "size": 4130},
              {"name": "Sum", "size": 791},
              {"name": "Variable", "size": 1124},
              {"name": "Variance", "size": 1876},
              {"name": "Xor", "size": 1101}
            ]
          },
          {
            "name": "scale",
            "children": [
              {"name": "IScaleMap", "size": 2105},
              {"name": "LinearScale", "size": 1316},
              {"name": "LogScale", "size": 3151},
              {"name": "OrdinalScale", "size": 3770},
              {"name": "QuantileScale", "size": 2435},
              {"name": "QuantitativeScale", "size": 4839},
              {"name": "RootScale", "size": 1756},
              {"name": "Scale", "size": 4268},
              {"name": "ScaleType", "size": 1821},
              {"name": "TimeScale", "size": 5833}
            ]
          },
          {
            "name": "util",
            "children": [
              {"name": "Arrays", "size": 8258},
              {"name": "Colors", "size": 10001},
              {"name": "Dates", "size": 8217},
              {"name": "Displays", "size": 12555},
              {"name": "Filter", "size": 2324},
              {"name": "Geometry", "size": 10993},
              {
                "name": "heap",
                "children": [
                  {"name": "FibonacciHeap", "size": 9354},
                  {"name": "HeapNode", "size": 1233}
                ]
              },
              {"name": "IEvaluable", "size": 335},
              {"name": "IPredicate", "size": 383},
              {"name": "IValueProxy", "size": 874},
              {
                "name": "math",
                "children": [
                  {"name": "DenseMatrix", "size": 3165},
                  {"name": "IMatrix", "size": 2815},
                  {"name": "SparseMatrix", "size": 3366}
                ]
              },
              {"name": "Maths", "size": 17705},
              {"name": "Orientation", "size": 1486},
              {
                "name": "palette",
                "children": [
                  {"name": "ColorPalette", "size": 6367},
                  {"name": "Palette", "size": 1229},
                  {"name": "ShapePalette", "size": 2059},
                  {"name": "SizePalette", "size": 2291}
                ]
              },
              {"name": "Property", "size": 5559},
              {"name": "Shapes", "size": 19118},
              {"name": "Sort", "size": 6887},
              {"name": "Stats", "size": 6557},
              {"name": "Strings", "size": 22026}
            ]
          },
          {
            "name": "vis",
            "children": [
              {
                "name": "axis",
                "children": [
                  {"name": "Axes", "size": 1302},
                  {"name": "Axis", "size": 24593},
                  {"name": "AxisGridLine", "size": 652},
                  {"name": "AxisLabel", "size": 636},
                  {"name": "CartesianAxes", "size": 6703}
                ]
              },
              {
                "name": "controls",
                "children": [
                  {"name": "AnchorControl", "size": 2138},
                  {"name": "ClickControl", "size": 3824},
                  {"name": "Control", "size": 1353},
                  {"name": "ControlList", "size": 4665},
                  {"name": "DragControl", "size": 2649},
                  {"name": "ExpandControl", "size": 2832},
                  {"name": "HoverControl", "size": 4896},
                  {"name": "IControl", "size": 763},
                  {"name": "PanZoomControl", "size": 5222},
                  {"name": "SelectionControl", "size": 7862},
                  {"name": "TooltipControl", "size": 8435}
                ]
              },
              {
                "name": "data",
                "children": [
                  {"name": "Data", "size": 20544},
                  {"name": "DataList", "size": 19788},
                  {"name": "DataSprite", "size": 10349},
                  {"name": "EdgeSprite", "size": 3301},
                  {"name": "NodeSprite", "size": 19382},
                  {
                    "name": "render",
                    "children": [
                      {"name": "ArrowType", "size": 698},
                      {"name": "EdgeRenderer", "size": 5569},
                      {"name": "IRenderer", "size": 353},
                      {"name": "ShapeRenderer", "size": 2247}
                    ]
                  },
                  {"name": "ScaleBinding", "size": 11275},
                  {"name": "Tree", "size": 7147},
                  {"name": "TreeBuilder", "size": 9930}
                ]
              },
              {
                "name": "events",
                "children": [
                  {"name": "DataEvent", "size": 2313},
                  {"name": "SelectionEvent", "size": 1880},
                  {"name": "TooltipEvent", "size": 1701},
                  {"name": "VisualizationEvent", "size": 1117}
                ]
              },
              {
                "name": "legend",
                "children": [
                  {"name": "Legend", "size": 20859},
                  {"name": "LegendItem", "size": 4614},
                  {"name": "LegendRange", "size": 10530}
                ]
              },
              {
                "name": "operator",
                "children": [
                  {
                    "name": "distortion",
                    "children": [
                      {"name": "BifocalDistortion", "size": 4461},
                      {"name": "Distortion", "size": 6314},
                      {"name": "FisheyeDistortion", "size": 3444}
                    ]
                  },
                  {
                    "name": "encoder",
                    "children": [
                      {"name": "ColorEncoder", "size": 3179},
                      {"name": "Encoder", "size": 4060},
                      {"name": "PropertyEncoder", "size": 4138},
                      {"name": "ShapeEncoder", "size": 1690},
                      {"name": "SizeEncoder", "size": 1830}
                    ]
                  },
                  {
                    "name": "filter",
                    "children": [
                      {"name": "FisheyeTreeFilter", "size": 5219},
                      {"name": "GraphDistanceFilter", "size": 3165},
                      {"name": "VisibilityFilter", "size": 3509}
                    ]
                  },
                  {"name": "IOperator", "size": 1286},
                  {
                    "name": "label",
                    "children": [
                      {"name": "Labeler", "size": 9956},
                      {"name": "RadialLabeler", "size": 3899},
                      {"name": "StackedAreaLabeler", "size": 3202}
                    ]
                  },
                  {
                    "name": "layout",
                    "children": [
                      {"name": "AxisLayout", "size": 6725},
                      {"name": "BundledEdgeRouter", "size": 3727},
                      {"name": "CircleLayout", "size": 9317},
                      {"name": "CirclePackingLayout", "size": 12003},
                      {"name": "DendrogramLayout", "size": 4853},
                      {"name": "ForceDirectedLayout", "size": 8411},
                      {"name": "IcicleTreeLayout", "size": 4864},
                      {"name": "IndentedTreeLayout", "size": 3174},
                      {"name": "Layout", "size": 7881},
                      {"name": "NodeLinkTreeLayout", "size": 12870},
                      {"name": "PieLayout", "size": 2728},
                      {"name": "RadialTreeLayout", "size": 12348},
                      {"name": "RandomLayout", "size": 870},
                      {"name": "StackedAreaLayout", "size": 9121},
                      {"name": "TreeMapLayout", "size": 9191}
                    ]
                  },
                  {"name": "Operator", "size": 2490},
                  {"name": "OperatorList", "size": 5248},
                  {"name": "OperatorSequence", "size": 4190},
                  {"name": "OperatorSwitch", "size": 2581},
                  {"name": "SortOperator", "size": 2023}
                ]
              },
              {"name": "Visualization", "size": 16540}
            ]
          }
        ]
      }
      #console.log data
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
      .on('click', (d) -> zoom( if node == d.parent then root else d.parent))
      .append('svg')
      .attr('class', 'clip')
      .attr('width', (d) -> Math.max(0.01, d.dx - 1))
      .attr('height', (d) -> Math.max(0.01, d.dy - 1))
      .on('mouseover', (d) ->
        d3.select(@).select('rect')
        .attr('stroke', 'black')
        .attr('stroke-width', 5)
        d3.select(@).append('title')
        .text((d) ->
          'Parent: ' + d.parent.name + '\n' +
          'Name: ' + d.name + '\n' +
          'Depth: ' + d.depth
        )
      )
      .on('mouseout', (d) ->
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
          #          _label = null

          #          console.log data

          #id = '#'+ newInfo.name
          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()
          console.log "test"
          svg = container.append('svg').attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom)
          #svg.select("#remove").remove()
          _graph = svg.append('g').attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          ranges =
            xMin: d3.min data, (d) -> parseFloat d.x
            yMin: d3.min data, (d) -> parseFloat d.y

            xMax: d3.max data, (d) -> parseFloat d.x
            yMax: d3.max data, (d) -> parseFloat d.y

          #          $scope.on 'Charts: labels y', (events, data) ->
          #            _label = data

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
