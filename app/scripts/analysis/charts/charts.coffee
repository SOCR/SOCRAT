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
  (ctrlMngr,$scope) ->
    console.log 'mainchartsCtrl executed'
    _chart_data = null

    _updateData = () ->
      $scope.chartData = _chart_data

    $scope.$on 'charts:graphDiv', (event, data) ->
      _chart_data = data
      console.log data
      _updateData()
])



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
    _headers = null

    $scope.selector1={}
    $scope.selector2={}
    $scope.selector3={}
    $scope.graphInfo = {graph:"", x:"", y:"",z:""}
    $scope.graphs = [{name:'Bar Graph', value:0},{name:'Scatter Plot', value:1},{name:'Histogram', value:2},{name:'Bubble Chart', value:3},{name:'Pie Chart', value:4}]
    $scope.graphSelect = {}



    $scope.createGraph = () ->
      graphFormat = () ->
        obj = []
        if $scope.graphInfo.y is "" and $scope.graphInfo.z is ""
          obj = []
          i=1
          while i < _chartData[0].length
            tmp = {}
            tmp = JSON.stringify({x:_chartData[$scope.graphInfo.x][i].value})
            obj.push(JSON.parse(tmp))
            i++
        else if $scope.graphInfo.y isnt "" and $scope.graphInfo.z is ""
          obj = []
          i=1
          while i < _chartData[0].length
            tmp = {}
            tmp = JSON.stringify({x:_chartData[$scope.graphInfo.x][i].value , y:_chartData[$scope.graphInfo.y][i].value})
            obj.push(JSON.parse(tmp))
            i++
        else
          obj = []
          i=1
          while i < _chartData[0].length
            tmp = {}
            tmp = JSON.stringify({x:_chartData[$scope.graphInfo.x][i].value , y:_chartData[$scope.graphInfo.y][i].value, z:_chartData[$scope.graphInfo.z][i].value})
            obj.push(JSON.parse(tmp))
            i++

        console.log obj
        return obj
      console.log $scope.graphInfo
      send = graphFormat()
      results = {
        data: send
        xLab: _headers[$scope.graphInfo.x],
        yLab: _headers[$scope.graphInfo.y],
        zLab: _headers[$scope.graphInfo.z],
        name: $scope.graphInfo.graph
      }
      #_graphInfo = results
      #[_chartData[$scope.graphInfo.x], _chartData[$scope.graphInfo.y]]
      $rootScope.$broadcast 'charts:graphDiv', results

    $scope.changeName = ()->
      $scope.graphInfo.graph = $scope.graphSelect.name
      $scope.createGraph()

    $scope.changeVar = (selector,headers, ind) ->
      for h in headers
        if selector.value is h.value then $scope.graphInfo[ind] = parseFloat h.key
      $scope.createGraph()

    sb = ctrlMngr.getSb()

    # deferred = $q.defer()

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


.directive 'd3Charts', [
  () ->
    restrict:'E'
    template:"<div class='graph-container' style='height: 600px'></div>"
    link: (scope, elem, attr) ->
      margin = {top: 10, right: 40, bottom: 30, left:40}
      width = 900 - margin.left - margin.right
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
      _graph = null
      container = null
      pieData = null
      gdata = null

      makepieData = (data) ->
        pieMax = d3.max(data, (d)->parseFloat d.x)
        pieMin = d3.min(data, (d)->parseFloat d.x)
        a = 0
        b = 0
        c = 0
        d = 0
        e = 0
        f = 0
        g = 0
        rangeInt = (pieMax - pieMin)/7
#        console.log pieMin+rangeInt
        for da in data
          val = parseFloat da.x

#          console.log val, pieMin+rangeInt

          if val < (pieMin+rangeInt)
            a++
#            console.log a
          else if (pieMin+rangeInt) <= val < (pieMin+2*rangeInt)
            b++
#            console.log b
          else if (pieMin+2*rangeInt) <= val < (pieMin+3*rangeInt)
            c++
          else if (pieMin+3*rangeInt) <= val < (pieMin+4*rangeInt)
            d++
          else if (pieMin+4*rangeInt) <= val < (pieMin+5*rangeInt)
            e++
          else if (pieMin+5*rangeInt) <= val < (pieMin+6*rangeInt)
            f++
          else if (pieMin+6*rangeInt) <= val < (pieMin+7*rangeInt)
            g++
        first = (pieMin+rangeInt).toFixed(2)+"-"+(pieMin).toFixed(2)
        second = (pieMin+2*rangeInt).toFixed(2)+"-"+(pieMin+rangeInt).toFixed(2)
        third = (pieMin+3*rangeInt).toFixed(2)+"-"+(pieMin+2*rangeInt).toFixed(2)
        fourth = (pieMin+4*rangeInt).toFixed(2)+"-"+(pieMin+3*rangeInt).toFixed(2)
        fifth = (pieMin+5*rangeInt).toFixed(2)+"-"+(pieMin+4*rangeInt).toFixed(2)
        sixth = (pieMin+6*rangeInt).toFixed(2)+"-"+(pieMin+5*rangeInt).toFixed(2)
        seventh = (pieMin+7*rangeInt).toFixed(2)+"-"+(pieMin+6*rangeInt).toFixed(2)
        #          switch val
        #            when val < (pieMin+rangeInt) then a++
        #            when val >= (pieMin+rangeInt) and val < (pieMin+2*rangeInt) then b++
        #            when val >= (pieMin+2*rangeInt) and val < (pieMin+3*rangeInt) then c++
        #            when val >= (pieMin+3*rangeInt) and val < (pieMin+4*rangeInt) then d++
        #            when val >= (pieMin+4*rangeInt) and val < (pieMin+5*rangeInt) then e++
        #            when val >= (pieMin+5*rangeInt) and val < (pieMin+6*rangeInt) then f++
        #            when val >= (pieMin+6*rangeInt) and val < (pieMin+7*rangeInt) then g++
        obj = {}
        obj[first] = a
        obj[second] = b
        obj[third] = c
        obj[fourth] = d
        obj[fifth] = e
        obj[sixth] = f
        obj[seventh] = g

        pieData = d3.entries obj
#        console.log pieData
        return pieData

      _drawStack = () ->
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
        .style('text-anchor', 'end')
        .attr('z-index', 1)
        .text gdata.xLab.value

        _graph.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text "Count"

        stack = d3.layout.stack()
        console.log(stack(data))
        groups = _graph.selectAll('g').data(stack(data)).enter().append('g')

        groups.selectAll('rect')
                      .data((d) -> d)
                      .enter().append()
                      .attr('x', (d,i) -> x i)
                      .attr('y', (d) -> y d.y0)
                      .attr('height', (d) -> y d.y)
                      .attr('width', x.rangeBand())


      _drawBar = () ->
#        makePairs(data)
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
        .style('text-anchor', 'end')
        .text gdata.xLab.value

        _graph.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text "Count"

        # create bar elements
        _graph.selectAll('rect')
        .data(data)
        .enter().append('rect')
        .attr('class', 'bar')
        .attr('x',(d)-> x d.x  )
        .attr('width', x.rangeBand())
        .attr('y', (d)-> y d.y )
        .attr('height', (d)-> (height - y d.y) )
        .attr('fill', 'steelblue')

      _drawHist = () ->
#values = d3.range(1000).map(d3.random.bates(10))
#console.log values
        container.append('input').attr('id', 'slider').attr('type','range').attr('min', '1').attr('max','10').attr('step', '1').attr('value','5')
        bins = null
        dataHist = null

        arr = []
        for d in data
          arr.push parseFloat d.x
#        console.log arr

        arr1 = data.map (d) -> parseFloat d.x
        x = d3.scale.linear().domain([0,d3.max arr]).range([0,width])


        plotHist = (bins) ->
          #          console.log bins
          dataHist = d3.layout.histogram().bins(bins)(arr)
          #          console.log dataHist
          #        _graph.select('g').remove()

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
          .style('text-anchor', 'end')
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
          .style("text-anchor", "end")
          .text "Count"

          bar = _graph.selectAll('.bar')
          .data(dataHist)

          #          bar.exit().remove()

          bar.enter()
          .append("g")
          #        .attr("class", "bar")
          #        .attr("transform",(d) -> return "translate(" + x(d.x) + "," + y(d.y) + ")")


          bar.append('rect')
          .style('fill', 'steelblue')
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

      _drawScatterplot = () ->

#        makePairs(data)


        x = d3.scale.linear().domain([xMin,xMax]).range([ 0, width ])
        y = d3.scale.linear().domain([yMin,yMax]).range([ height, 0 ])
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
        .style('text-anchor', 'end')
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
        .style("text-anchor", "end")
        .text gdata.yLab.value

        # add the tooltip area to the webpage
        tooltip = container
        .append('div')
        .attr('class', 'tooltip')
        .style('opacity', 0)

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

#        # draw legend
#        legend = _graph.selectAll('.legend')
#        .data(color.domain())
#        .enter().append('g')
#        .attr('class', 'legend')
#        .attr('transform', (d, i)-> 'translate(0,' + i * 20 + ')')
#        .text gdata.yLab.value
#
#        # draw legend colored rectangles
#        legend.append('rect')
#        .attr('x', width - 18)
#        .attr('width', 18)
#        .attr('height', 18)
#        .style('fill', color)
#
#        # draw legend text
#        legend.append('text')
#        .attr('x', width - 24)
#        .attr('y', 9)
#        .attr('dy', '.35em')
#        .style('text-anchor', 'end')
#        .text((d)-> d)

      _drawBubble = () ->
#        makeBubble(data)
        x = d3.scale.linear().domain([xMin,xMax]).range([ 0, width ])
        y = d3.scale.linear().domain([yMin,yMax]).range([ height, 0 ])
        xAxis = d3.svg.axis().scale(x).orient('bottom')
        yAxis = d3.svg.axis().scale(y).orient('left')

        r = d3.scale.linear()
              .domain([d3.min(data, (d)-> parseFloat d.z), d3.max(data, (d)-> parseFloat d.z)])
              .range([3,15])

        rValue = (d)->parseFloat d.z

        tooltip = container
        .append('div')
        .attr('class', 'tooltip')
        .style('opacity', 0)

        # x axis
        _graph.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call xAxis
        .append('text')
        .attr('class', 'label')
        .attr('x', width)
        .attr('y', -6)
        .style('text-anchor', 'end')
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
        .style("text-anchor", "end")
        .text gdata.yLab.value


        # create circle
        _graph.selectAll('.circle')
        .data(data)
        .enter().append('circle')
        .attr('fill', 'yellow')
        .attr('opacity', '0.7')
        .attr('stroke', 'orange')
        .attr('stroke-width', '2px')
        .attr('cx', (d)->x d.x)
        .attr('cy', (d)->y d.y)
        .attr('r', (d)-> r d.z)
        .on('mouseover', (d)->
          tooltip.transition().duration(200).style('opacity', .9)
          tooltip.html('<div style="background-color:white; padding:5px; border-radius: 5px">'+gdata.zLab.value+': '+ rValue(d)+'</div>')
          .style('left', d3.select(this).attr('cx') + 'px').style('top', d3.select(this).attr('cy') + 'px'))
        .on('mouseout', (d)->
          tooltip. transition().duration(500).style('opacity', 0))

      _drawPie = () ->
        makepieData(data)
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



      scope.$watch 'chartData', (newChartData) ->
        if newChartData
          gdata = newChartData
          data = newChartData.data
          console.log data

          #id = '#'+ newInfo.name
          container = d3.select(elem.find('div')[0])
          container.selectAll('*').remove()
          svg = container.append('svg').attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom)
          #svg.select("#remove").remove()
          _graph = svg.append('g').attr("transform", "translate(" + margin.left + "," + margin.top + ")")

          xMin = d3.min data, (d) -> parseFloat d.x
          yMin = d3.min data, (d) -> parseFloat d.y

          xMax = d3.max data, (d) -> parseFloat d.x
          yMax = d3.max data, (d) -> parseFloat d.y

          switch gdata.name
            when 'Bar Graph'
              _drawBar()
            when 'Bubble Chart'
              _drawBubble()
            when 'Histogram'
              _drawHist()
            when 'Pie Chart'
              _graph = svg.append('g').attr("transform", "translate(300,250)").attr("id", "remove")
              _drawPie()
            when 'Scatter Plot'
              _drawScatterplot()
            when 'Stacked Bar Chart'
              _drawStack()
]
