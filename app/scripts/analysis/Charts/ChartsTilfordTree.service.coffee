'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsTilfordTree extends BaseService
  
  initialize: ->

  drawTilfordTree: (InputData, container) ->
    data = JSON.parse(JSON.stringify(InputData)) # make the InputData immutable
    diameter = 600
    width = diameter
    height = diameter
    i = 0
    duration = 350
    root = data
    root.x0 = height / 2
    root.y0 = 0

    container.selectAll('svg').remove()

    tree = d3.layout.tree()
    .size([360, diameter / 2 - 10])
    .separation( (a, b) -> (if a.parent == b.parent then 1 else 2) / a.depth)

    diagonal = d3.svg.diagonal.radial()
    .projection((d) -> [d.y, d.x / 180 * Math.PI])

    _svg = container.append('svg')
    .attr('width', width)
    .attr('height', height)
    .append('g')
    .attr('transform', 'translate(' + diameter / 2 + ',' + diameter / 2 + ')')

    update = (source) ->
      # Compute new tree layout
      nodes = tree.nodes(root)
      links = tree.links(nodes)

      # Normalize for fixed-depth
      nodes.forEach((d) -> d.y = d.depth * 80)

      # Update the nodes
      node = _svg.selectAll('g.node')
      .data(nodes, (d) -> d.id || (d.id = ++i))

      # Enter any new nodes at the parent's previous position
      nodeEnter = node.enter().append('g')
      .attr('class', 'node')
      .on('click', click)
      .on('dblclick', (d) -> if d.url then window.open(d.url))

      nodeEnter.append('circle')
      .attr('r', 1e-6)
      .style('fill', (d) -> if d._children then 'lightstellblue' else '#fff')

      nodeEnter.append('text')
      .attr('x', 10)
      .attr('dy', '.35em')
      .attr('text-anchor', 'start')
      .text((d) -> d.name)
      .style('fill-opacity', 1e-6)

      # Transition nodes to their new position
      nodeUpdate = node.transition()
      .duration(duration)
      .attr('transform', (d) -> 'rotate(' + (d.x - 90) + ')translate(' + d.y + ')')

      nodeUpdate.select('circle')
      .attr('r', 4.5)
      .style('fill', (d) -> if d._children then 'lightsteelblue' else '#fff')

      nodeUpdate.select('text')
      .style('fill-opacity', 1)
      .attr('transform', (d) -> if d.x < 180 then 'translate(0)' else 'rotate(180)translate(-' + (d.name.length + 50) + ')')

      # Appropriate transform
      nodeExit = node.exit().transition().duration(duration).remove()

      nodeExit.select('circle').attr('r', 1e-6)

      nodeExit.select('text').style('fill-opacity', 1e-6)

      # Update the links
      link = _svg.selectAll('path.link')
      .data(links, (d) -> d.target.id)

      # Enter any new links at the parent's previous position
      link.enter().insert('path', 'g')
      .attr('class', 'link')
      .attr('d', (d) ->
        o = {x: source.x0, y: source.y0}
        return diagonal({source: o, target: o})
      )

      # Transition links to their new position
      link.transition()
      .duration(duration)
      .attr('d', diagonal)

      # Transition exiting nodes to the parent's new position
      link.exit().transition()
      .duration(duration)
      .attr('d', (d) ->
        o = {x: source.x0, y: source.y0}
        return diagonal({source: o, target: o})
      ).remove()

      # Stash the old position for transition
      nodes.forEach((d) ->
        d.x0 = d.x
        d.y0 = d.y
      )

    # Toggle children on click
    click = (d) ->
      if(d.children)
        d._children = d.children
        d.children = null
      else
        d.children = d._children
        d._children = null
      update(d)

    # Collapse nodes
    collapse = (d) ->
      if(d.children)
        d._children = d.children
        d._children.forEach(collapse)
        d.children = null

    # start with all children collapsed
    root.children.forEach(collapse)
    update(root)

    d3.select(self.frameElement).style('height', height)

