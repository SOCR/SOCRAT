'use strict'

module.exports = angular.module('app_analysis_charts', [])

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
  'app_analysis_charts_list'
  'app_analysis_charts_sendData'
  'app_analysis_charts_checkTime'
  (ctrlMngr, $scope, $rootScope, $stateParams, $q, dataTransform, list, sendData,time) ->
    _chartData = null
    _headers = null

    $scope.selector1 = {}
    $scope.selector2 = {}
    $scope.selector3 = {}
    $scope.selector4 = {}
    $scope.stream = false

    $scope.streamColors = [
      name: "blue"
      scheme: ["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"]
    ,
      name: "pink"
      scheme: ["#980043", "#DD1C77", "#DF65B0", "#C994C7", "#D4B9DA", "#F1EEF6"]
    ,
      name: "orange"
      scheme: ["#B30000", "#E34A33", "#FC8D59", "#FDBB84", "#FDD49E", "#FEF0D9"]
    ]

    $scope.graphInfo =
      graph: ""
      x: ""
      y: ""
      z: ""

    $scope.graphs = list.flat()
    $scope.graphSelect = {}
    $scope.labelVar = false
    $scope.labelCheck = null

    $scope.changeName = () ->
      $scope.graphInfo.graph = $scope.graphSelect.name

      if $scope.graphSelect.name is "Stream Graph"
        $scope.stream = true
      else
        $scope.stream = false

      if $scope.dataType is "NESTED"
        $scope.graphInfo.x = "initiate"
        sendData.createGraph($scope.data, $scope.graphInfo, {key: 0, value: "initiate"}, $rootScope, $scope.dataType, $scope.selector4.scheme)
      else
        sendData.createGraph(_chartData, $scope.graphInfo, _headers, $rootScope, $scope.dataType, $scope.selector4.scheme)

    $scope.changeVar = (selector,headers, ind) ->
      console.log $scope.selector4.scheme
      #if scope.graphInfo.graph is one of the time series ones, test variables for time format and only allow those when ind = x
      #only allow numerical ones for ind = y or z
      for h in headers
        if selector.value is h.value then $scope.graphInfo[ind] = parseFloat h.key
      sendData.createGraph(_chartData,$scope.graphInfo,_headers,$rootScope, $scope.dataType, $scope.selector4.scheme)


    sb = ctrlMngr.getSb()

    token = sb.subscribe
      msg:'take table'
      msgScope:['charts']
      listener: (msg, _data) ->
        switch _data.dataType
          when "FLAT"
            $scope.graphs = list.flat()
            $scope.dataType = "FLAT"
            _headers = d3.entries _data.header
            $scope.headers = _headers
            _chartData = dataTransform.format(_data.data)
            if time.checkForTime(_chartData)
              $scope.graphs = list.time()
          when "NESTED"
            $scope.graphs = list.nested()
            $scope.data = _data.data
            $scope.dataType = "NESTED"
            #$scope.header = {key: 0, value: "initiate"}

    sb.publish
      msg:'get table'
      msgScope:['charts']
      callback: -> sb.unsubscribe token
      data:
        tableName: $stateParams.projectId + ':' + $stateParams.forkId
])

.factory('app_analysis_charts_list', [
  () ->

    _getFlat = () ->
      flat = [
        name: 'Bar Graph'
        value: 0
        x: true
        y: true
        z: false
        message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
        xLabel: "Add x"
        yLabel: "Add y"
      ,
        name: 'Scatter Plot'
        value: 1
        x: true
        y: true
        z: false
        message: "Choose an x variable and a y variable."
        xLabel: "Add x"
        yLabel: "Add y"
      ,
        name: 'Histogram'
        value: 2
        x: true
        y: false
        z: false
        message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
        xLabel: ""
      ,
        name: 'Bubble Chart'
        value: 3
        x: true
        y: true
        z: true
        message: "Choose an x variable, a y variable and a radius variable."
        xLabel: "Add x"
        yLabel: "Add y"
        zLabel: "Add radius"
      ,
        name: 'Pie Chart'
        value: 4
        x: true
        y: false
        z: false
        message: "Choose one variable to put into a pie chart."
        xLabel: ""
      ,
        name: 'Normal Distribution'
        value: 5
        x: true
        y: false
        z: false
        message: "Choose one variable. This chart assumes there is a normal distribution."
        xLabel: ""
      ,
        name: 'Ring Chart'
        value: 4
        x: true
        y: false
        z: false
        message: "Choose one variable to put into a pie chart."
        xLabel: ""

      ]

    _getNested = () ->
      nested = [
        name: 'Stream Graph'
        value: 6
        x: true
        y: true
        z: true
        message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
        xLabel: "Add x (date)"
        yLabel: "Add y"
        zLabel: "Add key"
      ,
        name: 'Treemap'
        value: 7
        x: false
        y: false
        z: false
        message: ""
      ]

    _getTime = () ->
      time = [
        name: 'Area Chart'
        value: 5
        x: true
        y: true
        z: false
        message: "Pick date variable for x and numerical variable for y"
        xLabel: "Add x (date)"
        yLabel: "Add y"
      ,
        name: 'Line Chart'
        value: 8
        x: true
        y: true
        z: false
        message: "Choose a continuous variable for x and a numerical variable for y"
        xLabel: "Add x (date)"
        yLabel: "Add y"
      ,
        name: 'Bivariate Area Chart'
        value: 9
        x: true
        y: true
        z: true
        message: "Choose a date variable for x and two numerical variables for y and z"
        xLabel: "Add x (date)"
        yLabel: "Add y"
        zLabel: "Add z"
      ,
        name: 'Stream Graph'
        value: 6
        x: true
        y: true
        z: true
        message: "Pick date variable for x, a numerical variable for y, and a grouping key variable for z"
        xLabel: "Add x (date)"
        yLabel: "Add y"
        zLabel: "Add key"
      ,
        name: 'Bar Graph'
        value: 0
        x: true
        y: true
        z: false
        message: "Use option x to choose a numerical or categorical variable, or choose one categorical variable and one numerical variable."
        xLabel: "Add x"
        yLabel: "Add y"
      ,
        name: 'Scatter Plot'
        value: 1
        x: true
        y: true
        z: false
        message: "Choose an x variable and a y variable."
        xLabel: "Add x"
        yLabel: "Add y"
      ,
        name: 'Histogram'
        value: 2
        x: true
        y: false
        z: false
        message: "Choose an x variable. Use the slider below the histogram to adjust the number of bins."
        xLabel: ""
      ,
        name: 'Bubble Chart'
        value: 3
        x: true
        y: true
        z: true
        message: "Choose an x variable, a y variable and a radius variable."
        xLabel: "Add x"
        yLabel: "Add y"
        zLabel: "Add radius"
      ,
        name: 'Pie Chart'
        value: 4
        x: true
        y: false
        z: false
        message: "Choose one variable to put into a pie chart."
        xLabel: ""
      ,
        name: 'Normal Distribution'
        value: 5
        x: true
        y: false
        z: false
        message: "Choose one variable."
        xLabel: ""
      ,
        name: 'Ring Chart'
        value: 4
        x: true
        y: false
        z: false
        message: "Choose one variable to put into a pie chart."
        xLabel: ""
      ]


    flat: _getFlat
    nested: _getNested
    time: _getTime

])


.factory('app_analysis_charts_sendData', [
  () ->
    _createGraph = (chartData, graphInfo, headers, $rootScope, dataType, scheme_input) ->
      graphFormat = () ->
        console.log "dataType"
        console.log dataType

        if dataType is "NESTED" then return chartData
        else # dataType = "FLAT"
          obj = []
          len = chartData[0].length
          if graphInfo.y is "" and graphInfo.z is ""
            obj = []
            for i in [0...len] by 1
              tmp =
                x:  chartData[graphInfo.x][i].value
              obj.push tmp
          else if graphInfo.y isnt "" and graphInfo.z is ""
            obj = []
            for i in [0...len] by 1
              tmp =
                x:  chartData[graphInfo.x][i].value
                y:  chartData[graphInfo.y][i].value
              obj.push tmp
          else
            obj = []

            for i in [0...len] by 1
              tmp =
                x:  chartData[graphInfo.x][i].value
                y:  chartData[graphInfo.y][i].value
                z:  chartData[graphInfo.z][i].value
              obj.push tmp
          return obj

      streamColor = scheme_input
      console.log streamColor

      send = graphFormat()
      results =
        data: send
        xLab: headers[graphInfo.x],
        yLab: headers[graphInfo.y],
        zLab: headers[graphInfo.z],
        name: graphInfo.graph

      if graphInfo.graph is "Stream Graph"
        console.log("won't add property")
        results.scheme = streamColor


      $rootScope.$broadcast 'charts:graphDiv', results

    createGraph: _createGraph
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

.factory 'app_analysis_charts_checkTime',[
  () ->
#check if variable is date
    formats = [
      "MM/DD/YYYY",
      "M/DD/YYYY",
      "M/D/YYYY",
      "MM/DD/YY",
      "M/DD/YY",
      "M/D/YY",
      "L",
      "l",
      "DD-MMM-YY",
      "D-MMM-YY",
      "DDD-MMM-YYYY"
    ]

    #determines if an array is a date variable
    arrayDate = (array) ->
      for i in [0...array.length] by 1
        return false unless moment(array[i].value,formats,true).isValid()
      true

    checkData = (data) ->
      data.filter(arrayDate)
    _checkForTime = (data) ->
      if checkData(data).length is 0
        return false
      true

    _checkTimeChoice = (data) ->
      time = data.map (d) ->
        d.x
      alert "x is not a time variable" unless arrayDate d3.entries time

    checkForTime: _checkForTime
    checkTimeChoice: _checkTimeChoice
]

.factory 'stackBar', [
  () ->
    _stackedBar = (data,ranges,width,height,_graph, gdata,container) ->
      x = d3.scale.ordinal().rangeRoundBands([0, width-50])
      y = d3.scale.linear().range([0, height-50])
      z = d3.scale.ordinal().range(["darkblue", "blue", "lightblue"])

      stacked = d3.layout.stack()(data)
      console.log stacked

    stackedBar: _stackedBar
]

.factory 'line', [
  () ->
    _lineChart = (data,ranges,width,height,_graph, gdata,container) ->
#      formatDate = d3.time.format("%d-%b-%y")
      bisectDate = d3.bisector((d) -> d.x).left

      for d in data
        d.x = new Date d.x
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

      focus = _graph.append("g")
      .style("display", "none")

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

      #add tooltip
      focus.append("circle")
      .attr("class", "y")
      .style("fill", "white")
      .style("stroke", "steelblue")
      .style("stroke-width", "3px")
      .attr("r", 8)


      #point of label
      d0 = null
      val = null

      tooltip = container.append('div')
      .attr('class', 'tooltip')

      mousemove = () ->
        x0 = x.invert(d3.mouse(this)[0])

        i = bisectDate(data, x0, 1)
        #        console.log x0, i
        d0 = data[i - 1]
        d1 = data[i]
        d = x0 - d0.x > d1.x - x0 ? d1 : d0
        console.log d
        focus.select("circle.y")
        .attr("transform","translate(" + x(d0.x) + "," + y(d0.y) + ")")
        val = y.invert(d3.mouse(this)[0])
        tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+val+'</div>').style('top', height - y.invert(d3.mouse(this)[1]) + 'px').style('left', x.invert(d3.mouse(this)[0]) + 'px')


      _graph.append("rect")
      .attr("height", height)
      .attr("width", width)
      .style("fill", "none")
      .style("pointer-events", "all")
      .on("mouseover", () ->
        focus.style("display", null)
        console.log val
        tooltip.transition().duration(200).style('opacity', .9)

      )
      .on("mouseout", () ->
        focus.style("display", "none")
        tooltip.transition().duration(500).style('opacity', 0)
      )
      .on("mousemove", mousemove)


    lineChart: _lineChart
]

.factory 'streamGraph', [
  () ->

    _streamGraph = (data,ranges,width,height,_graph,scheme) ->
#      parseDate = d3.time.format("%d-%b-%y").parse
      #console.log parseDate data[0].x

      x = d3.time.scale()
      .range([0, width])

      y = d3.scale.linear()
      .range([height-10, 0])

      z = d3.scale.ordinal()
      .range(scheme) #["#045A8D", "#2B8CBE", "#74A9CF", "#A6BDDB", "#D0D1E6", "#F1EEF6"])

      console.log scheme


      xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom")
#      .ticks(d3.time.weeks)

      yAxis = d3.svg.axis()
      .scale(y)

      stack = d3.layout.stack()
      .offset("silhouette")
      .values((d) -> d.values)
      .x((d) -> d.x)
      .y((d) -> d.y)

      nest = d3.nest().key (d) -> d.z

      console.log data

      area = d3.svg.area()
      .interpolate("cardinal")
      .x((d)-> x(d.x))
      .y0((d)-> y(d.y0))
      .y1((d)->y(d.y0 + d.y))

      for d in data
        d.x = new Date d.x
        d.y = +d.y

      console.log nest.entries(data)

      layers = stack(nest.entries(data))

      x.domain(d3.extent(data, (d)-> d.x))
      y.domain([0, d3.max(data, (d) -> d.y0 + d.y)])

      console.log layers

      _graph.selectAll(".layer")
      .data(layers)
      .enter().append("path")
      .attr("class", "layer")
      .attr("d", (d) -> area(d.values))
      .style("fill", (d, i) ->z(i))

      _graph.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis)

      _graph.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + width + ", 0)")
      .call(yAxis.orient("right"))

      _graph.append("g")
      .attr("class", "y axis")
      .call(yAxis.orient("left"))

    streamGraph: _streamGraph
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
        tooltip.transition().duration(500).style('opacity', 0))

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

    _drawPie = (data,width,height,_graph, pie) ->
      radius = Math.min(width, height) / 2
      arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(0)

      if not pie
        arc.innerRadius(radius-60)

      #color = d3.scale.ordinal().range(["#ffffcc","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#0c2c84"])
      color = d3.scale.category20c()
      arcOver = d3.svg.arc()
      .outerRadius(radius + 10)
      if not pie
        arcOver.innerRadius(radius-50)

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

#testing
      nest = d3.nest().key (d) -> d.z

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
#console.log "xCat and yNum"
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
#      parseDate = d3.time.format("%d-%b-%y").parse

      for d in data
        d.x = new Date d.x
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
    _drawTreemap = (svg, width, height, container, data) ->

      maxDepth = 5
      sliderValue = 3

      sliderBar = container.append('input')
      .attr('id', 'slider')
      .attr('type', 'range')
      .attr('min', '1')
      .attr('max', maxDepth)
      .attr('step', '1')
      .attr('value', '3')

      plotTreemap = (sliderValue, maxDepth) ->
        color = d3.scale.category10()
        depthRestriction = sliderValue
        treemap = d3.layout.treemap()
        .size([width, height])
        .padding(4)
        .sticky(true)
        .value((d) ->d.size)

        filteredData = treemap.nodes(data).filter((d) -> d.depth < depthRestriction)
        leafNodes = treemap.nodes(data).filter((d) -> !d.children) # get all the leaf children
        findMaxDepth = (d) ->
          tmpMaxDepth = 0
          for i in [0..d.length-1] by 1
            if d[i].depth > tmpMaxDepth then tmpMaxDepth = d[i].depth
          return tmpMaxDepth
        maxDepth = findMaxDepth(leafNodes) + 1

        sliderBar.attr('max', maxDepth)

        node = svg.append('g')
        .selectAll('g.node')
        .data(filteredData)
        .enter().append('g')
        .attr('class', 'node')
        .attr('transform', (d) -> 'translate(' + d.x + ',' + d.y + ')')
        .append('svg')
        .attr('class', 'inner-node')
        .attr('width', (d) -> Math.max(0.01, d.dx - 1))
        .attr('height', (d) -> Math.max(0.01, d.dy - 1))
        .on('click', (d) -> if d.url then window.open(d.url))


        node.append('rect')
        .attr('width', (d) -> Math.max(0.01, d.dx - 1))
        .attr('height', (d) -> Math.max(0.01, d.dy - 1))
        .style('fill', (d) -> if d.children then color(d.name) else color(d.parent.name))
        .style('stroke', 'white')
        .style('stroke-width', '1px')
        .on('mouseover', () ->
          d3.select(@).append('title')
          .text((d) ->
            'Parent: ' + d.parent.name + '\n' +
              'Name: ' + d.name + '\n' +
              'Depth: ' + d.depth
          )
          d3.select(@)
          .style('stroke', 'black')
          .style('stroke-width', '3px')
        )
        .on('mouseout', () ->
          d3.select(@)
          .style('stroke', 'white')
          .style('stroke-width', '1px')
          d3.select(@).select('title').remove()
        )

        # update slider value
        $('#sliderText').remove()

        container.append('text')
        .attr('id', 'sliderText')
        .text('Treemap depth: ' + sliderValue)
        .attr('position', 'relative')
        .attr('left', '50px')

      plotTreemap(sliderValue, maxDepth) # default value of treemap depth

      d3.select('#slider')
      .on('change', () ->
        sliderValue = parseInt this.value
        plotTreemap(sliderValue, maxDepth)
      )

    drawTreemap: _drawTreemap
]

.factory 'bivariate', [
  () ->
    _bivariateChart = (height,width,_graph, data, gdata) ->
#      parseDate = d3.time.format("%d-%b-%y").parse

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

      area = d3.svg.area()
      .x((d) -> x(d.x))
      .y0((d) -> y(d.y))
      .y1((d) -> y(d.z))

      for d in data
        d.x = new Date d.x
        d.y = +d.y
        d.z = +d.z

      x.domain(d3.extent data, (d) -> d.x)
      y.domain([d3.min(data, (d) -> d.y), d3.max(data, (d) -> d.z)])

      console.log y.domain

      _graph.append("path")
      .datum(data)
      .attr("class", "area")
      .attr("d", area)
      .style('fill', 'steelblue')

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

    bivariateChart: _bivariateChart
]

.factory 'normal', [
  () ->
    distanceFromMean = 5

    extract = (data, variable) ->
      tmp = []
      for d in data
        tmp.push +d[variable]
      tmp

    getRightBound = (middle,step) ->
      middle + step *distanceFromMean

    getLeftBound = (middle,step) ->
      middle - (step*distanceFromMean)

    sort = (values) ->
      values.sort (a,b) -> a-b

    getVariance = (values,mean) ->
      temp = 0
      numberOfValues = values.length
      while( numberOfValues--)
        temp += Math.pow( (values[numberOfValues ] - mean), 2 )

      return temp / values.length

    getSum = (values) ->
      values.reduce (previousValue, currentValue) -> previousValue + currentValue

    getGaussianFunctionPoints = (std,mean,variance,leftBound,rightBound) ->
      data = []
      for i in [leftBound...rightBound] by 1
        data.push({x:i,y:(1/(std*Math.sqrt(Math.PI*2)))*Math.exp(-(Math.pow(i-mean,2)/ (2*variance)))})
      console.log(data)
      data;

    getMean = (valueSum,numberOfOccurrences) ->
      valueSum / numberOfOccurrences

    getZ = (x,mean,standardDerivation) ->
      (x-mean)/standardDerivation

    getWeightedValues = (values) ->
      weightedValues= {}
      data= []
      lengthValues = values.length
      for i in [0...lengthValues] by 1
        label = values[i].toString()
        if(weightedValues[label])
          weightedValues[label].weight++
        else
          weightedValues[label]={weight :1,value :label}
          data.push(weightedValues[label])
      return data

    getRandomNumber = (min,max) ->
      Math.round((max-min) * Math.random() + min)

    getRandomValueArray = (data) ->
      values = []
      length = data.length
      for i in [1...length]
        values.push data[Math.floor(Math.random() * data.length)]
      return values

    drawNormalCurve = (data, width, height, _graph) ->

      toolTipElement = _graph.append('div')
      .attr('class', 'tooltipGauss')
      .attr('position', 'absolute')
      .attr('width', 15)
      .attr('height', 10)

      showToolTip = (value, positionX, positionY) ->
        toolTipElement.style('display', 'block')
        toolTipElement.style('top', positionY+10+"px")
        toolTipElement.style('left', positionX+10+"px")
        toolTipElement.innerHTML = " Z = "+value

      hideToolTip = () ->
        toolTipElement.style('display', 'none')
        toolTipElement.innerHTML = " "

      console.log extract(data, "x")
      sample = sort(getRandomValueArray(extract(data,"x")))
      sum = getSum(sample)
      min = sample[0]
      max = sample[sample.length - 1]
      mean = getMean(sum, sample.length)
      variance = getVariance(sample, mean)
      standardDerivation =  Math.sqrt(variance)
      rightBound = getRightBound(mean, standardDerivation)
      leftBound = getLeftBound(mean,standardDerivation)
      bottomBound = 0
      topBound = 1/(standardDerivation*Math.sqrt(Math.PI*2))
      gaussianCurveData = getGaussianFunctionPoints(standardDerivation,mean,variance,leftBound,rightBound)
      radiusCoef = 5

      xScale = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])
      yScale = d3.scale.linear().range([height, 0]).domain([bottomBound, topBound])

      xAxis = d3.svg.axis().ticks(20)
      .scale(xScale)

      yAxis = d3.svg.axis()
      .scale(yScale)
      .ticks(10)
      .tickPadding(0)
      .orient("right")

      lineGen = d3.svg.line()
                .x (d) -> xScale(d.x)
                .y (d) -> yScale(d.y)
                .interpolate("basis")

      _graph.append('svg:path')
      .attr('d', lineGen(gaussianCurveData))
      .data([gaussianCurveData])
      .attr('stroke', 'black')
      .attr('stroke-width', 2)
      .on('mousemove', (d) -> showToolTip(getZ(xScale.invert(d3.event.x),mean,standardDerivation).toLocaleString(),d3.event.x,d3.event.y))
      .on('mouseout', (d) -> hideToolTip())
      .attr('fill', "aquamarine")
#      .style("opacity", .2)

      _graph.append("svg:g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + (height) + ")")
      .call(xAxis)

      _graph.append("svg:g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + (xScale(mean)) + ",0)")
      .call(yAxis)

      _graph.append("svg:g")
      .append("text")      #text label for the x axis
      .attr("x", width/2 + width/4  )
      .attr("y", 20  )
      .style("text-anchor", "middle")
      .style("fill", "white")
#      .text(seriesName)

# Weighted Values
#      _graph.selectAll("circle")
#      .data(getWeightedValues(sample)).enter().append("circle")
#      #text label for the x axis
#      .attr("cx", (d) -> xScale(d.value))
#      .attr("cy", height)
#      .attr("r", (d) -> radiusCoef)
#      .style("fill","red")
#      .style("opacity",.5)

    getRandomValueArray: getRandomValueArray
    getGaussianFunctionPoints: getGaussianFunctionPoints
    getWeightedValues: getWeightedValues
    getSum: getSum
    getMean: getMean
    sort: sort
    getVariance: getVariance
    getLeftBound: getLeftBound
    getZ: getZ
    getRightBound: getRightBound
    drawNormalCurve: drawNormalCurve

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
  'line',
  'bivariate',
  'stackBar',
  'normal',
  'app_analysis_charts_checkTime'
  (scatterPlot, histogram, pie, bubble, bar, streamGraph, area, treemap, line, bivariate, stackedBar, normal, time) ->
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
          scheme = newChartData.scheme
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
            when 'Ring Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              pie.drawPie(data,width,height,_graph,false)
            when 'Scatter Plot'
              scatterPlot.drawScatterPlot(data,ranges,width,height,_graph,container,gdata)
            when 'Stacked Bar Chart'
              stackBar.stackedBar(data,ranges,width,height,_graph, gdata,container)
            when 'Stream Graph'
              time.checkTimeChoice(data)
              streamGraph.streamGraph(data,ranges,width,height,_graph, scheme)
            when 'Area Chart'
              time.checkTimeChoice(data)
              area.drawArea(height,width,_graph, data, gdata)
            when 'Treemap'
              treemap.drawTreemap(svg, width, height, container, data)
            when 'Line Chart'
              time.checkTimeChoice(data)
              line.lineChart(data,ranges,width,height,_graph, gdata,container)
            when 'Bivariate Area Chart'
              time.checkTimeChoice(data)
              bivariate.bivariateChart(height,width,_graph, data, gdata)
            when 'Normal Distribution'
              normal.drawNormalCurve(data, width, height, _graph)
            when 'Pie Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              pie.drawPie(data,width,height,_graph,true)

]
