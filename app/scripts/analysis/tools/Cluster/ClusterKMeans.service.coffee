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

    @name = 'K-means'
    @timer = null
    @ks = [2..10]
    @lables = null
    @iter = 0
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
      k: ks
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
      distances = (_distance(row, mean, 'euclidean') for row in data)
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
    cov = _matrixMultiply matrixT, matrix
    cov = cov.map((row) -> row.map((el) -> el / (n - 1)))

    # calculate pseudo-inverse covariance matrix
    tCov = new jsfeat.matrix_t l, l, jsfeat.F32_t | jsfeat.C1_t
    covData = []
    (covData.push(e) for e in row for row in cov)
    tCov.data = covData
    tCovInv = new jsfeat.matrix_t l, l, jsfeat.F32_t | jsfeat.C1_t
    jsfeat.linalg.svd_invert tCovInv, tCov

    invCov = (0 for e1 in [0..l - 1] for e2 in [0..l - 1])
    for row, i in invCov
      for col, j in row
        invCov[i][j] = tCovInv.data[2 * i + j]

    invCov

  assignSamples: (data, centroids, distanceType) ->
    labels = []
    for row in data
      distances = (_distance(row, ctr.val, distanceType) for ctr in centroids)
      labels.push distances.indexOf(Math.min.apply @, distances)
    labels

  runKMeans: (data, k, maxIter, centroids, distanceType, uniqueLabels, trueLabels=null) ->

    evaluateAccuracy = (labels, trueLabels, uniqueLabels) ->
      accuracy = {}
      # unique labels available for assignment
      uniqueEstLabels = _getUniqueLabels labels

      for k in uniqueLabels
        # get true indices for label k
        kTrueLabelIdxs = (i for x, i in trueLabels when x is k)
        # get calculated labels by true indices
        kEstLabels = (x for x, i in labels when i in kTrueLabelIdxs) # numeric
        estLabelCounts = uniqueEstLabels.map (uniqueEstLabel) ->
          # count number of occurrences for each unique estimated label
          counts = kEstLabels.reduce (n, val) ->
            n + (val is uniqueEstLabel)
          , 0
          counts
        # find first most abundant label index
        mostFrequentEstLabelIdx = estLabelCounts.indexOf Math.max.apply(null, estLabelCounts) # numeric
        currentEstLabel = uniqueEstLabels[mostFrequentEstLabelIdx]
        # remove label that was taken
        uniqueEstLabels.splice mostFrequentEstLabelIdx, 1
        accuracy[k] = estLabelCounts[mostFrequentEstLabelIdx] / kTrueLabelIdxs.length

      accs = (acc for own label, acc of accuracy)
      accuracy['average'] = accs.reduce((r, s) -> r + s) / accs.length
      accuracy

    step = (data, centroids) ->
      maxIter--
      console.log 'Iteration: ' + maxIter
      console.log 'Centroids: '
      console.table centroids

      labels = _assignSamples data, centroids, distanceType
      means = _updateMeans data, centroids, labels

      console.log 'New means: '
      console.table means
      if not _arrayEqual means.map((x) -> x.idx), centroids.map((x) -> x.idx)
        centroids = means
        _updateGraph(data, means.map((x) -> x.val), labels)
      else
        maxIter = 0

      centroids: centroids
      labels: labels

    reportAccuracy = (estLabels, trueLabels, uniqueLabels) ->
      acc = {}
      if _computeAcc
        acc = evaluateAccuracy estLabels, trueLabels, uniqueLabels
      _graph.showResults acc

    run = ->
      # main loop
      if maxIter
        res = step data, centroids
        centroids = res.centroids
        labels = res.labels
      else
        clearInterval interval
        console.log 'K-Means done.'
        if _computeAcc
          labels = _assignSamples data, centroids, distanceType
        reportAccuracy labels, trueLabels, uniqueLabels

    runMahalanobis = ->
      # main loop
      if maxIter
        maxIter--
        console.log 'Iteration: ' + maxIter
        console.log 'Centroids: '
        console.table centroids

        means = centroids.slice()

        for row, i in data

          ctrDistances = (_distance(row, ctr.val, distanceType, covMats[j]) for ctr, j in centroids)
          ctrIdx = ctrDistances.indexOf(Math.min.apply @, ctrDistances)

          if ctrIdx isnt lbls[i]
            lbls[i] = ctrIdx
            centroids = _updateMeans data, centroids, lbls
            _updateGraph(data, centroids.map((x) -> x.val), lbls)
            for ctr, j in centroids
              covMats[j] = _updatePrecisionMatrix(data, j, lbls)

        if _arrayEqual(means.map((x) -> x.idx), centroids.map((x) -> x.idx))
          maxIter = 0

      else
        clearInterval interval
        console.log 'K-Means done.'
        reportAccuracy lbls, trueLabels, uniqueLabels

    if distanceType is 'mahalanobis'
      labels = _assignSamples data, centroids, 'euclidean'
      centroids = _updateMeans data, centroids, labels
      covMats = []
      lbls = labels.slice()
      for ctr, ctrIdx in centroids
        covMats.push _updatePrecisionMatrix(data, ctrIdx, labels)
      interval = setInterval runMahalanobis, 1000
    else
      interval = setInterval run, 1000

  forgyInit: (data, k) ->
    centroids = @initCentroids data, k
    centroids: centroids
    initLabels: @assignSamples data, centroids, 'euclidean'

  randomPartitionInit: (data, k) ->
    initLabels = @initLabels data.length - 1, k
    centroids: @updateMeans data, uniqueLabels, initLabels
    initLabels: initLabels

  kMeansPlusPlusInit: (data, k) ->
    false

  initClusters: (data, k, initMethod, distance) ->
    # try to initiate clusters
    clusters = (@inits.filter (init) -> init.name.toLowerCase() is initMethod.toLowerCase()).shift().method(data, k)
    if clusters
      @clusters = clusters
      if distance in @metrics.getNames() and distance.toLowerCase() is 'mahalanobis'
        @labels = @assignSamples data, @clusters.centroids, 'euclidean'
        @clusters.centroids = @updateMeans data, @clusters.centroids, labels
        @covMats = []
        for ctr, ctrIdx in @clusters.centroids
          @covMats.push @updatePrecisionMatrix(data, ctrIdx, labels)
        @labels = @labels.slice()

  updateCentroidsMahalanobis: (data, centroids, lbls) ->
    for row, i in data
      ctrDistances = (_distance(row, ctr.val, distanceType, @covMats[j]) for ctr, j in centroids)
      ctrIdx = ctrDistances.indexOf(Math.min.apply @, ctrDistances)

      if ctrIdx isnt lbls[i]
        lbls[i] = ctrIdx
        centroids = @updateMeans data, centroids, lbls
        for ctr, j in centroids
          @covMats[j] = @updatePrecisionMatrix(data, j, lbls)

  runIter: (data, centroids, distance) ->
    console.log 'Iteration: ' + @iter
    console.log 'Centroids: '
    console.table centroids

    if distance.toLowerCase() isnt 'mahalanobis'
      @labels = @assignSamples data, centroids, distance
      @means = @updateMeans data, centroids, labels
    else
      @means = centroids.slice()
      @updateCentroidsMahalanobis data, centroids

    console.log 'New means: '
    console.table means
    if not _arrayEqual means.map((x) -> x.idx), centroids.map((x) -> x.idx)
      centroids = means
      _updateGraph(data, means.map((x) -> x.val), labels)
    else
      maxIter = 0

  step: (data, k, init, distance) ->
    # init at the first iteration
    if @iter is 0 and data?
      # save data to runtime variable
      @data = data
      initClusters(data, k, init, distance)
    if @iter < @maxIter
      @iter++
      res = @runIter data, @clusters.centroids, distance
      @centroids = res.centroids
      @labels = res.labels
    else
      #TODO: finalize

  run: ->
