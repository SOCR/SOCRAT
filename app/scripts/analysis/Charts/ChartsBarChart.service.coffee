'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsBarChart extends BaseService

  initialize: ->

  drawBar: (width,height,data,_graph,labels,ranges) ->

    padding = 50
    x = d3.scale.linear().range([ padding, width - padding ])
    y = d3.scale.linear().range([ height - padding, padding ])

    xAxis = d3.svg.axis().scale(x).orient('bottom')
    yAxis = d3.svg.axis().scale(y).orient('left')

#    x.domain([d3.min(data, (d)->parseFloat d.x), d3.max(data, (d)->parseFloat d.x)])
#    y.domain([d3.min(data, (d)->parseFloat d.y), d3.max(data, (d)->parseFloat d.y)])

    x_min = ranges.xMin
    x_max = ranges.xMax

    # x_padding is used to avoid drawing a bar at the edge of x-axis
    x_range = x_max - x_min
    x_padding = x_range * 0.05

    y_max = ranges.yMax
    y_padding = y_max * 0.05

    x.domain([x_min - x_padding, x_max + x_padding])
    y.domain([0, y_max + y_padding])

    xAxisLabel_x = width - 80
    xAxisLabel_y = 40

    yAxisLabel_x = -70
    yAxisLabel_y = -70

    color = d3.scale.category20()

	# Input original data
    # Return a mapped object
    # key: category
    # value: counts
    CateVar = { X:1, Y:2, Z:3, C:4 }
    categoryToCounts = (data, variable) ->
      categoryHash = {}
      for i in [0..data.length-1] by 1
        currentCategory = 0
        switch variable
          when CateVar.X
            currentCategory = data[i].x
          when CateVar.Y
            currentCategory = data[i].y
          when CateVar.Z
            currentCategory = data[i].z
          when CateVar.C
            currentCategory = data[i].c
        categoryHash[currentCategory] = categoryHash[currentCategory] || 0
        ++categoryHash[currentCategory]
      return d3.entries categoryHash

    # Input a mapped object with kay and value, value must be integer
    getCategory = (object) ->
       array = []
       for i in [0..object.length-1] by 1
         array.push(object[i].key)
       return array

    # Return data in the following structure:
    # [ {x:'x-variable', cat1: count, cat2,: count}, {...} ]
    getStackRawDataArray = (data) ->
      xSet = {}

      # Determine x-variable set
      # each object in set is in this data structure
      # { category: { total: #} }
      catToCount = categoryToCounts(data, CateVar.X)

      for category in catToCount
        xSet[category.key] = { total: category.value }

      # Initialize each category to be 0 count
      xSetD3entry = d3.entries xSet
      colorCategoryArray = getCategory(categoryToCounts(data, CateVar.Z))

      for xObj in xSetD3entry
        for category in colorCategoryArray
          xSet[xObj.key][category] = 0

      # Determine counts of color variables (z-variable) for each x-variable
      for i in [0..data.length-1] by 1
        object = xSet[data[i].x]
        ++object[data[i].z]

      # Convert xSet to flat array
      # Data structure: [{ x: 'x-var', cat1: count, cat2: count, total: count}, {...} ]
      array = []
      Object.keys(xSet).forEach((key) ->
        object = {}
        setObject = xSet[key]
        object['x'] = key
        Object.keys(setObject).forEach((objKey) -> object[objKey] = setObject[objKey])
        array.push(object)
      )
      return array

    # without y variable
    if not data[0].y
        yCounts = categoryToCounts(data, CateVar.X)
        yMax = 0
        for variable in yCounts
          if variable.value > yMax
            yMax = variable.value
        yPadding = 1
        y.domain([0, yMax + yPadding])

        x = d3.scale.ordinal().rangeRoundBands([padding, width-padding], .1)
        xAxis = d3.svg.axis().scale(x).orient('bottom').ticks(2)
        x.domain(yCounts.map (d) -> d.key)

        # create bar elements

        if not data[0].z # without color variable (z variable)
          _graph.selectAll('rect')
          .data(yCounts)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('x',(d)-> x d.key  )
          .attr('width', x.rangeBand())
          .attr('y', (d)-> y d.value )
          .attr('height', (d)-> Math.abs(height - y d.value) - padding)
          .attr('fill', (d) -> if not data[0].z? then 'steelblue' else color(d.key))

        else # with color variable
          stackRawData = getStackRawDataArray(data)
          colorCategoryArray = getCategory(categoryToCounts(data, CateVar.Z))

          dataIntermediate = colorCategoryArray.map((c) ->
            return stackRawData.map((d) ->
              return {x: d.x, y: d[c], key: c}
            )
          )

          layers = d3.layout.stack()(dataIntermediate)

          x.domain(layers[0].map((d) -> d.x)).rangeRoundBands([padding, width-padding], .1)
          y.domain([0, d3.max(layers[layers.length-1], (d) -> d.y0 + d.y)]).nice()

          color.domain(colorCategoryArray)

          layer = _graph.selectAll('.layer')
            .data(layers)
            .enter()
            .append('g')
            .attr('class', 'layer')
            .style('fill', (d, i) -> color(i))

          layer.selectAll('rect')
          .data((d) -> d)
          .enter()
          .append('rect')
          .attr('x', (d) -> x d.x)
          .attr('y', (d) -> y (d.y + d.y0))
          .attr('height', (d) -> (y d.y0) - (y (d.y + d.y0)))
          .attr('width', x.rangeBand())

        # x axis
        # draw x axis with labels and move in from the size by the amount of padding
        x_axis = _graph.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + (height - padding) + ')')
        .call(xAxis)

        # y axis
        # draw y axis with labels and move in from the size by the amount of padding
        y_axis = _graph.append('g')
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

	# with y variable
    else
      # y is categorical
      if isNaN data[0].y
        y = d3.scale.ordinal().rangeRoundBands([padding, height-padding], .1)
        y.domain(data.map (d) -> d.y)
        yAxis = d3.svg.axis().scale(y).orient('left')
        data.sort((a, b) -> b.x - a.x )

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
        .attr('fill', (d) -> if not data[0].z? then 'steelblue' else color(d.z))

        # x axis
        x_axis = _graph.append('g')
        .attr('class', 'x axis')
        .attr('transform', 'translate(0,' + (height-padding) + ')')
        .call xAxis
        .style('font-size', '16px')

        # y axis
        y_axis = _graph.append('g')
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

      # y variable is numerical
      else if !isNaN data[0].y
        # x is categorical, y is numberical
        if isNaN data[0].x
          x = d3.scale.ordinal().rangeRoundBands([padding, width-padding], .1)
          x.domain(data.map (d) -> d.x)
          xAxis = d3.svg.axis().scale(x).orient('bottom')
          data.sort((a, b) -> b.y - a.y )

          # create bar elements
          minYvalue = d3.min(data, (d)-> d.y)
          _graph.selectAll('rect')
          .data(data)
          .enter().append('rect')
          .attr('class', 'bar')
          .attr('x',(d)-> x d.x )
          .attr('width', x.rangeBand())
          .attr('y', (d)-> y d.y)
          .attr('height', (d)-> Math.abs(height - y d.y) - padding)
          .attr('fill', (d) -> if not data[0].z? then 'steelblue' else color(d.z))

          # x axis
          x_axis = _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + (height - padding) + ')')
          .call xAxis
          .style('font-size', '16px')

          # y axis
          y_axis = _graph.append('g')
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
        else # both x and y are numerical
          data.sort((a, b) -> b.y - a.y )

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
          .attr('fill', (d) -> if not data[0].z? then 'steelblue' else color(d.z))

          # x axis
          x_axis = _graph.append('g')
          .attr('class', 'x axis')
          .attr('transform', 'translate(0,' + (height - padding) + ')')
          .call xAxis
          .style('font-size', '16px')

          # y axis
          y_axis = _graph.append('g')
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

    # rotate text on x axis
    _graph.selectAll('.x.axis text')
    .attr('transform', (d) ->
      'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
    .style('font-size', '16px')
    .style('text-anchor', 'middle')

    # Show tick lines
    x_axis.selectAll(".x.axis line").style('stroke', 'black')
    y_axis.selectAll(".y.axis line").style('stroke', 'black')

    # make x y axis thin
    _graph.selectAll('.x.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
    _graph.selectAll('.y.axis path')
    .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})

    # Legend
    if not data[0].z? # if z variable is undefined
      return

    legendRectSize = 8
    legendSpacing = 5
    textSize = 11
    horz = width - padding - 2 * legendRectSize
    vert = textSize

    # Legend Title
    _graph.append('text')
    .attr('class', 'label')
    .attr('transform', 'translate(' + horz + ',' + vert + ')')
    .text gdata.zLab.value

    # Legend list data
    colorCategoryArray = getCategory(categoryToCounts(data, CateVar.Z))

    legend = _graph.selectAll('.legend')
    .data(if data[0].y then color.domain() else colorCategoryArray)
    .enter()
    .append('g')
    .attr('class', 'legend')
    .attr('transform', (d, i) ->
      ht = legendRectSize + legendSpacing # height of each legend
      h = horz
      v = vert + legendRectSize + i * ht
      return 'translate(' + h + ',' + v + ')'
    )

    # Legend rect
    legend.append('rect')
    .attr('width', legendRectSize)
    .attr('height', legendRectSize)
    .style('fill', (d, i) -> if data[0].y then color(d) else color(i))
    .style('stroke', (d, i) -> if data[0].y then color(d) else color(i))

    # Legend Text
    legend.append('text')
    .attr('x', legendRectSize + legendSpacing)
    .attr('y', legendRectSize)
    .text((d) -> d)
    .style('font-size', textSize + 'px')






