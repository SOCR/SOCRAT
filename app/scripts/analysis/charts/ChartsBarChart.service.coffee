'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBarChart extends BaseService

  initialize: ->

  drawBar: (width,height,data,_graph,gdata) ->
    padding = 50
    x = d3.scale.linear().range([ padding, width - padding ])
    y = d3.scale.linear().range([ height - padding, padding ])

    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')
    x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
    y.domain([d3.min(data, (d)->parseFloat d.y), d3.max(data, (d)->parseFloat d.y)])
    
    xAxisLabel_x = width - 80
    xAxisLabel_y = 40
    
    yAxisLabel_x = -70
    yAxisLabel_y = -70


	
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
        #console.log counts

        # check if all the counts are the same
        # if the all counts are the same, need to fix y.domain([min, max])
        sameCounts = true 
        for i in [1..counts.length-1] by 1
          if counts[i].value != counts[0].value
           sameCounts = false
        #console.log sameCounts
        x = d3.scale.ordinal().rangeRoundBands([padding, width-padding], .1)
        xAxis = d3.svg.axis().scale(x).orient('bottom')
        x.domain(counts.map (d) -> d.key)
        if sameCounts
          y.domain([0, counts[0].value])
        else 
          y.domain([d3.min(counts, (d)-> parseInt d.value), d3.max(counts, (d)-> parseInt d.value)])
        
        # create bar elements
        _graph.selectAll('rect')
        .data(counts)
        .enter().append('rect')
        .attr('class', 'bar')
        .attr('x',(d)-> x d.key  )
        .attr('width', x.rangeBand())
        .attr('y', (d)-> y d.value )
        .attr('height', (d)-> Math.abs(height - y d.value) - padding)
        .attr('fill', 'steelblue')

        # draw x axis with labels and move in from the size by the amount of padding
        _graph.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + (height - padding) + ')')
        .call xAxis

        # draw y axis with labels and move in from the size by the amount of padding
        _graph.append('g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(' + padding + ',0)' )
        .call yAxis
        .style('font-size', '16px')
        
         # make x y axis thin
        _graph.selectAll('.x.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        _graph.selectAll('.y.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
   
        # now rotate text on x axis
        # solution based on idea here: https://groups.google.com/forum/?fromgroups#!topic/d3-js/heOBPQF3sAY
        # first move the text left so no longer centered on the tick
        # then rotate up to get 40 degrees.
        _graph.selectAll('.x.axis text')
        .attr('transform', (d) ->
         'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)'
        ).style('font-size', '16px')
        
        # Titles on x-axis 
        _graph.append('text')
        .attr('class', 'label')
        .attr('text-anchor', 'middle')
        .attr('transform', 'translate(' + width + ',' + (height-padding/2) + ')')
        .text gdata.xLab.value
        
        # Titles on y-axis 
        _graph.append('text')
        .attr('class', 'label')
        .attr('text-anchor', 'middle')
        .attr('transform', 'translate(0,' + padding/2 + ')')
        .text "Counts"

 
      else #data is numerical and only x. height is rect width, width is x of d.x,
  #y becomes the categorical
        y = d3.scale.ordinal().rangeRoundBands([height-padding, padding], .1)
        yAxis = d3.svg.axis().scale(y).orient('left')
        y.domain((d) -> d.x)
        
        # create bar elements
        minXvalue = d3.min(data, (d)-> d.x)
        rectWidth = (height-2*padding)/data.length
        _graph.selectAll('rect')
        .data(data)
        .enter().append('rect')
        .attr('class', 'bar')
        .attr('x', padding  )
        .attr('width', (d)-> (x d.x) - (x minXvalue))
        .attr('y', (d,i)-> i*rectWidth + padding)
        .attr('height', rectWidth)
        .attr('fill', 'steelblue')
        
        # x axis
        _graph.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + (height - padding) + ')')
        .call xAxis
        
        # y axis
        _graph.append('g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(' + padding + ',0)' )
        .call yAxis
        
        # make x y axis thin
        _graph.selectAll('.x.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        _graph.selectAll('.y.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        
        # rotate text on x axis
        _graph.selectAll('.x.axis text')
        .attr('transform', (d) ->
         'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)'
        ).style('font-size', '16px')
        
        # Title on x axis 
        _graph.append('text')
        .attr('class', 'label')
        .attr('text-anchor', 'middle')
        .attr('transform', 'translate(' + width + ',' + (height-padding/2) + ')')
        .text gdata.xLab.value

  #with y
    else
  #y is categorical
      if isNaN data[0].y

        y = d3.scale.ordinal().rangeRoundBands([padding, height-padding], .1)
        y.domain(data.map (d) -> d.y)
        yAxis = d3.svg.axis().scale(y).orient('left')
        
        # create bar elements
        minXvalue = d3.min(data, (d)-> d.x)
        _graph.selectAll('rect')
        .data(data)
        .enter().append('rect')
        .attr('class', 'bar')
        .attr('x', padding)
        .attr('width', (d) -> Math.abs((x d.x) - (x minXvalue)))
        .attr('y', (d)-> y d.y )
        .attr('height', y.rangeBand())
        .attr('fill', 'steelblue')
        
        # x axis
        _graph.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + (height-padding) + ')')
        .call xAxis
        .style('font-size', '16px')
        
        # y axis
        _graph.append('g')
        .attr('class', 'y axis')
        .attr('transform', 'translate(' + padding + ',0)' )
        .call yAxis
        .style('font-size', '16px')
        
        # make x y axis thin
        _graph.selectAll('.x.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        _graph.selectAll('.y.axis path')
        .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
        
        # rotate text on x axis
        _graph.selectAll('.x.axis text')
        .attr('transform', (d) ->
          'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
        .style('font-size', '16px')
        
        # Title on x-axis
        _graph.append('text')
        .attr('class', 'label')
        .attr('text-anchor', 'middle')
        .attr('transform', 'translate(' + width + ',' + (height-padding/2) + ')')
        .text gdata.xLab.value
        
        # Title on y-axis
        _graph.append('text')
        .attr('class', 'label')
        .attr('text-anchor', 'middle')
        .attr('transform', 'translate(0,' + padding/2 + ')')
        .text gdata.yLab.value

      else if !isNaN data[0].y
        if isNaN data[0].x
          x = d3.scale.ordinal().rangeRoundBands([padding, width-padding], .1)
          x.domain(data.map (d) -> d.x)
          xAxis = d3.svg.axis().scale(x).orient('bottom')
          
          # create bar elements
          minYvalue = d3.min(data, (d)-> d.y)
          console.log minYvalue
          _graph.selectAll('rect')
          .data(data)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('x',(d)-> x d.x )
          .attr('width', x.rangeBand())
          .attr('y', (d)-> y d.y)
          .attr('height', (d)-> Math.abs(height - y d.y) - padding)
          .attr('fill', 'steelblue')
          
          # x axis
          _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + (height - padding) + ')')
          .call xAxis
          .style('font-size', '16px')
          
          # y axis
          _graph.append('g')
          .attr('class', 'y axis')
          .attr('transform', 'translate(' + padding + ',0)' )
          .call yAxis
          .style('font-size', '16px')
          
          # make x y axis thin
          _graph.selectAll('.x.axis path')
          .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
          _graph.selectAll('.y.axis path')
          .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
          
          # rotate text on x axis
          _graph.selectAll('.x.axis text')
          .attr('transform', (d) ->
            'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
          .style('font-size', '16px')
        
          # Title on x-axis
          _graph.append('text')
          .attr('class', 'label')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(' + width + ',' + (height-padding/2) + ')')
          .text gdata.xLab.value
          
          # Title on y-axis
          _graph.append('text')
          .attr('class', 'label')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(0,' + padding/2 + ')')
          .text gdata.yLab.value

          
        else
          # both x and y are numerical
          
          # create bar elements
          rectWidth = (width - 2*padding)/data.length
          _graph.selectAll('rect')
          .data(data)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('x',(d)-> x d.x  )
          .attr('width', rectWidth)
          .attr('y', (d)-> y d.y )
          .attr('height', (d)-> Math.abs(height - y d.y) - padding)
          .attr('fill', 'steelblue')
          
          # x axis
          _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + (height - padding) + ')')
          .call xAxis
          .style('font-size', '16px')
          
          # y axis
          _graph.append('g')
          .attr('class', 'y axis')
          .attr('transform', 'translate(' + padding + ',0)' )
          .call yAxis
          .style('font-size', '16px')
          
          # make x y axis thin
          _graph.selectAll('.x.axis path')
          .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
          _graph.selectAll('.y.axis path')
          .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
   
          # rotate text on x axis
          _graph.selectAll('.x.axis text')
          .attr('transform', (d) ->
            'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
          .style('font-size', '16px')
        
          # Title on x-axis
          _graph.append('text')
          .attr('class', 'label')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(' + width + ',' + (height-padding/2) + ')')
          .text gdata.xLab.value
          
          # Title on y-axis
          _graph.append('text')
          .attr('class', 'label')
          .attr('text-anchor', 'middle')
          .attr('transform', 'translate(0,' + padding/2 + ')')
          .text gdata.yLab.value

  
          
