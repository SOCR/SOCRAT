'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_cluster_kMeans
  @type: service
  @desc: Performs k-means clustering
###

module.exports = class ClusterKMeans extends BaseService
  @inject '$timeout', 'app_analysis_cluster_metrics'

  initialize: () ->
    @metrics = @app_analysis_cluster_metrics
    @jsfeat = require 'jsfeat'

    @name = 'K-means'
    @timer = null
    @ks = [2..10]
    @lables = null
    @iter = 0
    @done = off
    @maxIter = 100
    @inits = [
      name: 'Forgy'
      method: @forgyInit
    ,
      name: 'Random patition'
      method: @randomPartitionInit
    ,
      name: 'k-means++'
      method: @kMeansPlusPlusInit
    ]

    #runtime variables
    @data = null
    @clusters = null

    # module parameters
    @params =
      k: @ks
      distance: @metrics.getNames()
      init: @inits.map (init) -> init.name

  getName: -> @name
  getParams: -> @params

  getUniqueLabels: (labels) -> labels.filter (x, i, a) -> i is a.indexOf x

  arrayEqual: (x, y) ->
    a = x.slice().sort()
    b = y.slice().sort()
    a.length is b.length and a.every (elem, i) -> elem is b[i]

  matrixMultiply: (a, b) ->
    c = (0 for d1 in a.length for d2 in d3.transpose(b))
    for row, i in a
      for col, j in d3.transpose(b)
        c[i][j] = (row[k] * col[k] for el, k in row).reduce (t, s) -> t + s
    c

  initCentroids: (data, k) ->
    nRows = data.length
    centroids = []
    for ctr in [0..k - 1]
      ctrIdx = Math.floor(Math.random() * nRows)
      if centroids.length and ctrIdx is not centroids[ctr - 1].idx
        ctrIdx = Math.floor(Math.random() * nRows)
      centroids.push
        val: data[ctrIdx]
        idx: ctrIdx
    centroids

  initLabels: (l, k) ->
    labels = []
    labels.push Math.floor(Math.random() * k) for i in [0..l]
    labels

  updateMeans: (data, centroids, labels) ->
    ctrData = ([] for ctr in centroids)
    for row, rowIdx in data
      ctrData[labels[rowIdx]].push row

    means = []
    for ctr, ctrIdx in ctrData
      colSums = (0 for col in data[0])
      for row in ctr
        for el, elIdx in row
          colSums[elIdx] += el
      colMeans = colSums.map (x) -> x / ctr.length
      means.push colMeans

    centroids = []
    for mean in means
      distances = (@metrics.distance(row, mean, 'euclidean') for row in data)
      ctrIdx = distances.indexOf(Math.min.apply @, distances)
      # trying not to assign the same point
      if ctrIdx not in centroids.map((x) -> x.idx)
        centroids.push
          val: data[ctrIdx]
          idx: ctrIdx
      else
        distances = distances.splice(ctrIdx)
        ctrIdx = distances.indexOf(Math.min.apply @, distances)
        centroids.push
          val: data[ctrIdx]
          idx: ctrIdx
    centroids

  updatePrecisionMatrix: (data, ctrIdx, labels) ->
    matrix = []
    for i in [0..data.length]
      if labels[i] is ctrIdx
        matrix.push data[i].slice()
    #      (matrix.push(row) for row, i in data when labels[i] is ctrIdx)
    n = matrix.length

    matrixT = d3.transpose matrix
    l = matrixT.length
    means = (col.reduce((t, s) -> t + s) / n for col in matrixT)

    for row, i in matrix
      for col, j in row
        matrix[i][j] = col - means[j]
    matrixT = d3.transpose(matrix)

    cov = (0 for e1 in [0..l - 1] for e2 in [0..l - 1])
    cov = @matrixMultiply matrixT, matrix
    cov = cov.map((row) -> row.map((el) -> el / (n - 1)))

    # calculate pseudo-inverse covariance matrix
    tCov = new @jsfeat.matrix_t l, l, @jsfeat.F32_t | @jsfeat.C1_t
    covData = []
    (covData.push(e) for e in row for row in cov)
    tCov.data = covData
    tCovInv = new @jsfeat.matrix_t l, l, @jsfeat.F32_t | @jsfeat.C1_t
    @jsfeat.linalg.svd_invert tCovInv, tCov

    invCov = (0 for e1 in [0..l - 1] for e2 in [0..l - 1])
    for row, i in invCov
      for col, j in row
        invCov[i][j] = tCovInv.data[2 * i + j]

    invCov

  assignSamples: (data, centroids, distanceType) ->
    labels = []
    for row in data
      distances = (@metrics.distance(row, ctr.val, distanceType) for ctr in centroids)
      labels.push distances.indexOf(Math.min.apply @, distances)
    labels

  ## Init functions
  # have to preserve context with =>
  forgyInit: (data, k) =>
    centroids = @initCentroids data, k
    centroids: centroids
    initLabels: @assignSamples data, centroids, 'euclidean'

  randomPartitionInit: (data, k) =>
    initLabels = @initLabels data.length - 1, k
    centroids: @updateMeans data, [0..k-1], initLabels
    initLabels: initLabels

  kMeansPlusPlusInit: (data, k) =>
    false

  initClusters: (data, k, initMethod, distance) ->
    # try to initiate clusters
    clusters = (@inits.filter (init) -> init.name.toLowerCase() is initMethod.toLowerCase()).shift().method(data, k)
    if clusters
      centroids = clusters.centroids
      labels = clusters.initLabels
      # if mahalanobis distance, need to precompute covariance matrices
      metrics = @metrics.getNames().map Function.prototype.call, String.prototype.toLowerCase
      if distance.toLowerCase() in metrics and distance.toLowerCase() is 'mahalanobis'
        labels = @assignSamples data, centroids, 'euclidean'
        centroids = @updateMeans data, centroids, labels
        covMats = []
        for ctr, ctrIdx in centroids
          covMats.push @updatePrecisionMatrix(data, ctrIdx, labels)

      centroids: centroids
      labels: labels
      covMats: covMats
    else
      # if couldn't init clusters
      false

  updateCentroidsMahalanobis: (data, centroids, labels, covMats) ->
    lbls = labels.slice()
    for row, i in data
      ctrDistances = (@metrics.mahalanobis(row, ctr.val, covMats[j]) for ctr, j in centroids)
      ctrIdx = ctrDistances.indexOf(Math.min.apply @, ctrDistances)
      if ctrIdx isnt lbls[i]
        lbls[i] = ctrIdx
        centroids = @updateMeans data, centroids, lbls
        for ctr, j in centroids
          covMats[j] = @updatePrecisionMatrix(data, j, lbls)

    centroids: centroids
    labels: lbls
    covMats: covMats

  # run first iteration
  prepFirstIter: (data, k, init, distance) ->
    # parse data object
    labels = data.labels
#    if data.data[0].length > 2
#      clusterWholeDataset = on
#      xCol = data.xCol
#      yCol = data.yCol
#    else
#      clusterWholeDataset = off
    data = (row.map(Number) for row in data.data)
    k = Number k
    if labels
      @uniqueLabels = @getUniqueLabels(labels)
      # compute accuracy only when # of clusters is equal to number of unique labels
      #        _computeAcc = if uniqueLabels.length is k then on else off
      @computeAcc = data.acc
    else
      uniqueLabels = [0..k-1]
      @computeAcc = off
    init = init.toLowerCase()
    distance = distance.toLowerCase()
    # initialize clusters
    initRes = @initClusters(data, k, init, distance)
    initRes.data = data
    initRes

  # run one iteration of k-means
  runIter: (data, centroids, labels, distance, covMats=@covMats) ->
    console.log 'Centroids: '
    console.table centroids

    if distance.toLowerCase() isnt 'mahalanobis'
      labels = @assignSamples data, centroids, distance
      centroids = @updateMeans data, centroids, labels
    else
#      means = centroids.slice()
      res = @updateCentroidsMahalanobis data, centroids, labels, covMats
      labels = res.labels
      centroids = res.centroids
      covMats = res.covMats

    console.log 'New means: '
    console.table centroids

    centroids: centroids
    labels: labels
    covMats: covMats

  # control a step of clustering
  step: (data, k, init, distance) ->
    # init at the first iteration
    if !@done and @iter is 0 and data?
      firstRes = @prepFirstIter data, k, init, distance
      @data = firstRes.data
      @centroids = firstRes.centroids
      @labels = firstRes.labels
      @covMats = firstRes.covMats unless !firstRes.covMats?
      @distance = distance
    if @centroids? and @iter < @maxIter and !@done
      @iter++
      console.log 'Iteration: ' + @iter
      res = @runIter @data, @centroids, @labels, @distance
      if @arrayEqual(@centroids.map((x) -> x.idx), res.centroids.map((x) -> x.idx))
        @done = on
      else
        @centroids = res.centroids
        @labels = res.labels
        @covMats = res.covMats unless !res.covMats?
    else
      console.log 'k-means finished'
      #TODO: finalize
    centroids: @centroids
    labels: @labels
    done: @done

  reset: ()->
    @done = off
    @iter = 0
