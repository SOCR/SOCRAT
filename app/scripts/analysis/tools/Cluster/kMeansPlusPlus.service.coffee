'use strict'

initialize: ->

# Select a random point

initCentroids: (data, k) ->
    nRows = data.length
    centroids = []
    ctrIdx = Math.floor(Math.random() * nRows)
    centroids.push
        val: data[ctrIdx]
        idx: ctrIdx
    centroids
    # For each data point x, compute D(x)
  for row in data
    distances = (@metrics.distance(row, centroids.val, distanceType))
  
  
