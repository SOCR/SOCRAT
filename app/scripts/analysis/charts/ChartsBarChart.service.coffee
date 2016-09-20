'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBarChart extends BaseService

  initialize: ->

  drawBar: (width,height,data,_graph,gdata) ->
    
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
