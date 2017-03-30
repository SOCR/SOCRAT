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
