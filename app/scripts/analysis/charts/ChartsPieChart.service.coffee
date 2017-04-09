'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsPieChart extends BaseService

  initialize: ->
    @valueSum = 0

  makePieData: (data) ->
    @valueSum = 0
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
        @valueSum++
    else # data is string
      for i in [0..data.length-1] by 1
        currentVar = data[i].x
        counts[currentVar] = counts[currentVar] || 0
        counts[currentVar]++
        @valueSum++
    obj = d3.entries counts
    return obj

  drawPie: (data,width,height,_graph, pie) -> # "pie" is a boolean
      radius = Math.min(width, height) / 2
      outerRadius = radius
      arc = d3.svg.arc()
      .outerRadius(outerRadius)
      .innerRadius(0)

      if not pie # ring chart
        arc.innerRadius(radius-60)

      color = d3.scale.category20c()
<<<<<<< HEAD
      
      arcOver = d3.svg.arc()
      .outerRadius(radius + 10)
      
=======

      arcOver = d3.svg.arc()
      .outerRadius(radius + 10)

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      if not pie # ring chart
        arcOver.innerRadius(radius-50)

      pie = d3.layout.pie()
      .value((d)-> d.value)
      .sort(null)

      formatted_data = @makePieData data
      sum = @valueSum
      clickOn = (false for [0..formatted_data.length-1])
<<<<<<< HEAD
     
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      # PIE ARCS / SLICES

      arcs = _graph.selectAll(".arc")
      .data(pie(formatted_data))
      .enter()
      .append('g')
      .attr("class", "arc")
<<<<<<< HEAD
      
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      paths = arcs.append('path')
      .attr('d', arc)
      .attr('fill', (d) -> color(d.data.value))
      .on('mouseover', handleMouseOver)
      .on('mouseout', handleMouseOut)
      .on('click', handleClick)
<<<<<<< HEAD
      
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      # Create Event Handlers for mouse
      handleMouseOver = (d, i) ->
       if clickOn[i] is false
        # Use d3 to select element
        d3.select(this)
<<<<<<< HEAD
        .attr("stroke","white") 
        .transition()
        .attr("d", arcOver)
        .attr("stroke-width",3)
        
=======
        .attr("stroke","white")
        .transition()
        .attr("d", arcOver)
        .attr("stroke-width",3)

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
        # bold the label
        d3.select(this.parentNode)
        .select('text')
        .attr('font-weight', 'bold')
<<<<<<< HEAD
        
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      handleMouseOut= (d, i) ->
        if clickOn[i] is false
          d3.select(this)
          .transition()
          .attr('d', arc)
          .attr("stroke", "none")
<<<<<<< HEAD
          
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
          # unbold the label
          d3.select(this.parentNode)
          .select('text')
          .attr('font-weight', 'normal')

<<<<<<< HEAD
        
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      handleClick= (d,i) ->
        if clickOn[i] is true
          clickOn[i] = false
          d3.select(this)
          .transition()
          .attr('d', arc)
          .attr("stroke", 'none')
<<<<<<< HEAD
          
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
          # unbold the label
          d3.select(this.parentNode)
          .select('text')
          .attr('font-weight', 'normal')
<<<<<<< HEAD
          
=======

>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
        else
          clickOn[i] = true
          d3.select(this)
          .attr('stroke', 'white')
          .transition()
          .attr('d', arcOver)
          .attr('stroke', 3)
<<<<<<< HEAD
          
          		  
=======


>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      arcs.append('path')
      .attr('d', arc)
      .attr('fill', (d) -> color(d.data.value))
      .on('mouseover', handleMouseOver)
      .on('mouseout', handleMouseOut)
      .on('click', handleClick)
<<<<<<< HEAD
      
      
=======


>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      # Specify where to put text label
      arcs.append('text')
      .attr('class', 'text')
      .attr('transform', (d) ->
        c = arc.centroid(d)
        x = c[0]
        y = c[1]
        h = Math.sqrt(x*x + y*y)
<<<<<<< HEAD
        desiredLabelRad = 220
        'translate(' + (x/h * desiredLabelRad) + ',' + (y/h * desiredLabelRad) + ')'
=======
        desiredLabelRad = 240
        left = false
        if x < 0
          desiredLabelRad += -.42*x
          left = true
        'translate(' + (x/h * desiredLabelRad) + ',' + (y/h * desiredLabelRad - .42*x*left) + ')'
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      ).transition()
      .text (d) =>
        d.data.key + ' (' + parseFloat(100 * d.data.value / sum).toFixed(1) + '%)'
      .style('font-size', '16px')

<<<<<<< HEAD
      
      
      
      
      
      
      

      
      
=======










>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe

