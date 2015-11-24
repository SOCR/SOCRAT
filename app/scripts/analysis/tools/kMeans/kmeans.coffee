'use strict'

kMeans = angular.module('app_analysis_kMeans', [])

.factory('app_analysis_kMeans_constructor', [
  'app_analysis_kMeans_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'kMeans init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_kMeans_manager', [
  () ->
    _sb = null

    _msgList =
      outgoing: ['get data']
      incoming: ['take data']
      scope: ['kMeans']

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

.controller('kMeansMainCtrl', [
  'app_analysis_kMeans_manager'
  'app_analysis_kMeans_calculator'
  '$scope'
  '$timeout'
  (ctrlMngr, kMeans, $scope, $timeout) ->
    console.log 'kMeansMainCtrl executed'

    _dataPoints = null
    _means = null
    _assignments = null

    prettifyArrayOutput = (arr) ->
      if arr?
        arr = arr.map (x) -> x.toFixed 3
        '[' + arr.toString().split(',').join('; ') + ']'

    updateChartData = () ->
      $scope.dataPoints = _dataPoints
      $scope.means = _means
      $scope.assignments = _assignments

    _update = (dataPoints, means=null, assignments=null) ->
      _dataPoints = dataPoints
      _means = means if means
      _assignments = assignments if assignments
      # safe enforce $scope.$digest to activate directive watchers
      $timeout updateChartData

    graph =
      update: _update

    updateChartData()
    kMeans.setGraph graph
])

.controller('kMeansSidebarCtrl', [
  'app_analysis_kMeans_manager'
  'app_analysis_kMeans_calculator'
  '$scope'
  '$stateParams'
  '$q'
  (ctrlMngr, kmeans, $scope, $stateParams, $q) ->
    console.log 'kMeansSidebarCtrl executed'

    sb = ctrlMngr.getSb()

    $scope.cols = []
    $scope.k = '2'
    $scope.dist = 'Euclidean'
    $scope.initMethod = 'Forgy'

    deferred = $q.defer()

    # subscribe for incoming message with data
    token = sb.subscribe
      msg: 'take data'
      msgScope: ['kMeans']
      listener: (msg, data) ->
        _data = data
        $scope.cols = _data.header
        [firstCol, secondCol, ..., lastCol] = $scope.cols
        $scope.xCol = firstCol
        $scope.yCol = secondCol
        $scope.labelCol = lastCol
        $scope.run = ->
          xCol = _data.header.indexOf $scope.xCol
          yCol = _data.header.indexOf $scope.yCol
          if $scope.labelson
            labelCol = _data.header.indexOf $scope.labelCol
            labels = (row[labelCol] for row in _data.data)
          else
            labels = null
          data = ([row[xCol], row[yCol]] for row in _data.data)
          kmeans.run data, $scope.k, $scope.dist, $scope.initMethod, labels

    sb.publish
      msg: 'get data'
      msgScope: ['kMeans']
      callback: -> sb.unsubscribe token
      data:
        tableName: $stateParams.projectId + ':' + $stateParams.forkId
        promise: deferred
])

.factory('app_analysis_kMeans_calculator', [
  () ->

    _graph = null
    _computeAcc = off
    _maxIter = 20

    _setGraph = (graph) ->
      _graph = graph

    _getUniqueLabels = (labels) ->
      labels.filter (x, i, a) -> i is a.indexOf x

    _distance = (v1, v2, type='euclidean', s=[]) ->

      euclidean = (v1, v2) ->
        total = 0
        for i in [0..v1.length - 1]
          total += Math.pow(v2[i] - v1[i], 2)
        Math.sqrt(total)

      manhattan = (v1, v2) ->
        total = 0
        for i in [0..v1.length - 1]
          total += Math.abs(v2[i] - v1[i]);
        total

      max = (v1, v2) ->
        max = 0
        for i in [0..v1.length - 1]
          max = Math.max(max , Math.abs(v2[i] - v1[i]));
        max

      mahalanobis = (v1, v2, s) ->

        l = v1.length
        invCov = s

        diff = (v1[k] - v2[k] for k in [0..l - 1])
        total = 0
        for row, i in invCov
          for el, j in row
            total += invCov[i][j] * Math.pow(diff[i], 2 - i - j) * Math.pow(diff[j], i + j)
        Math.sqrt(total)

      if _arrayEqual v1, v2
        return 0
      else
        switch type.toLowerCase()
          when 'manhattan' then return manhattan v1, v2
          when 'max' then return max v1, v2
          when 'mahalanobis' then return mahalanobis v1, v2, s
          else return euclidean v1, v2

    _arrayEqual = (x, y) ->
      a = x.slice().sort()
      b = y.slice().sort()
      a.length is b.length and a.every (elem, i) -> elem is b[i]

    _matrixMultiply = (a, b) ->
      c = (0 for d1 in a.length for d2 in d3.transpose(b))
      for row, i in a
        for col, j in d3.transpose(b)
          c[i][j] = (row[k] * col[k] for el, k in row).reduce (t, s) -> t + s
      c

    _initCentroids = (data, k) ->
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

    _initLabels = (l, k) ->
      labels = []
      labels.push Math.floor(Math.random() * k) for i in [0..l]
      labels

    _updateMeans = (data, centroids, labels) ->
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

    _updatePrecisionMatrix = (data, ctrIdx, labels) ->
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

    _assignSamples = (data, centroids, distanceType) ->
      labels = []
      for row in data
        distances = (_distance(row, ctr.val, distanceType) for ctr in centroids)
        labels.push distances.indexOf(Math.min.apply @, distances)
      labels

    _runKMeans = (data, k, maxIter, centroids, distanceType, uniqueLabels, trueLabels=null) ->

      evaluateAccuracy = (labels, trueLabels, uniqueLabels) ->
        # TODO: make accuracy work for k > 2
        accs = [0]
        for k in uniqueLabels
          # get true indices for label k
          kLabelIdxs = (i for x, i in trueLabels when x is k)
          # get calculated labels by true indices
          kLabels = (uniqueLabels[x] for x, i in labels when i in kLabelIdxs)
          kTrueLabels = (x for x in trueLabels when x is k)
          accK = kLabels.map((x, idx) -> x - kTrueLabels[idx]).reduce (r, s) -> r + s
          accs.push Math.abs(accK)
        acc = (trueLabels.length - accs.reduce((r, s) -> r + s)) / trueLabels.length
        acc = if acc < 0.5 then 1 - acc else acc

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
          _graph.update(data, means.map((x) -> x.val), labels)
        else
          maxIter = 0

        centroids: centroids
        labels: labels

      run = () ->
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
            acc = evaluateAccuracy labels, trueLabels, uniqueLabels
            console.log 'Accuracy: ' + acc * 100 + '%'
          else
            acc = ''
#          Core.fireEvent
#            msg: 'kmeans_done'
#            data: acc * 100

      runMahalanobis = () ->
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
              _graph.update(data, centroids.map((x) -> x.val), lbls)
              for ctr, j in centroids
                covMats[j] = _updatePrecisionMatrix(data, j, lbls)

          if _arrayEqual(means.map((x) -> x.idx), centroids.map((x) -> x.idx))
            maxIter = 0

        else
          clearInterval interval
          console.log 'K-Means done.'
          if _computeAcc
            acc = evaluateAccuracy lbls, trueLabels, uniqueLabels
            console.log 'Accuracy: ' + acc * 100 + '%'
          else
            acc = ''
#          Core.fireEvent
#            msg: 'kmeans_done'
#            data: acc * 100

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

    _init = (data, k, distanceType, initMethod, labels=null) ->
      data = (row.map(Number) for row in data)

      k = Number k
      console.log 'K: ' + k

      if labels
        uniqueLabels = _getUniqueLabels(labels)
        # compute accuracy only when # of clusters is equal to number of unique labels
        _computeAcc = if uniqueLabels.length is k then on else off
      else
        uniqueLabels = [0..k-1]
        _computeAcc = off

      distanceType = distanceType.toLowerCase()
      initMethod = initMethod.toLowerCase()

      _graph.update data

      if initMethod is 'forgy'
        centroids = _initCentroids data, k
        initLabels = _assignSamples data, centroids, 'euclidean'
      else
        initLabels = _initLabels data.length - 1, k
        centroids = _updateMeans data, uniqueLabels, initLabels

      _graph.update data, centroids.map((x) -> x.val), initLabels

      console.log 'Starting K-Means'
      _runKMeans data, k, _maxIter, centroids, distanceType, uniqueLabels, labels

    run: _init
    setGraph: _setGraph
  ])

.directive 'appKmeans', [
  '$parse'
  'app_analysis_kMeans_calculator'
  ($parse, kMeans) ->
    restrict: 'E'
    template: "<svg width='100%' height='600'></svg>"
    link: (scope, elem, attr) ->

      MARGIN_LEFT = 40
      MARGIN_TOP = 20

      _graph = null
      _xScale = null
      _yScale = null
      _color = null
      _meanLayer = null

      _drawDataPoints = (dataPoints) ->
        pointDots = _graph.selectAll('.pointDots').data(dataPoints)
        pointDots.enter().append('circle').attr('class','pointDots')
        .attr('r', 3)
        .attr('cx', (d) -> _xScale(d[0]))
        .attr('cy', (d) -> _yScale(d[1]))

      _redraw = (dataPoints, means, assignments) ->
        assignmentLines = _meanLayer.selectAll('.assignmentLines').data(assignments)
        assignmentLines.enter().append('line').attr('class','assignmentLines')
        .attr('x1', (d, i) -> _xScale(dataPoints[i][0]))
        .attr('y1', (d, i) -> _yScale(dataPoints[i][1]))
        .attr('x2', (d, i) -> _xScale(means[d][0]))
        .attr('y2', (d, i) -> _yScale(means[d][1]))
        .attr('stroke', (d) -> _color(d))

        assignmentLines.transition().duration(500)
        .attr('x2', (d, i) -> _xScale(means[d][0]))
        .attr('y2', (d, i) -> _yScale(means[d][1]))
        .attr('stroke', (d) -> _color(d))

        meanDots = _meanLayer.selectAll('.meanDots').data(means)
        meanDots.enter().append('circle').attr('class','meanDots')
        .attr('r', 5)
        .attr('stroke', (d, i) -> _color(i))
        .attr('stroke-width', 3)
        .attr('fill', 'white')
        .attr('cx', (d) -> _xScale(d[0]))
        .attr('cy', (d) -> _yScale(d[1]))

        meanDots.transition().duration(500)
        .attr('cx', (d) -> _xScale(d[0]))
        .attr('cy', (d) -> _yScale(d[1]))
        meanDots.exit().remove()

      rawSvg = elem.find("svg")[0]
      svg = d3.select(rawSvg)
      _graph = svg.append('g').attr('transform', 'translate(' +  MARGIN_LEFT + ',' + MARGIN_TOP + ')')
      _meanLayer = _graph.append('g')
      _color = d3.scale.category10()

      scope.$watchCollection 'dataPoints', (newDataPoints) ->
        if newDataPoints
          xDataPoints = (row[0] for row in newDataPoints)
          yDataPoints = (row[1] for row in newDataPoints)
          minXDataPoint = d3.min xDataPoints
          maxXDataPoint = d3.max xDataPoints
          minYDataPoint = d3.min yDataPoints
          maxYDataPoint = d3.max yDataPoints
          _xScale = d3.scale.linear().domain([minXDataPoint, maxXDataPoint]).range([0, 600])
          _yScale = d3.scale.linear().domain([minYDataPoint, maxYDataPoint]).range([0, 500])
          _drawDataPoints newDataPoints

      scope.$watchCollection 'assignments', (newAssignments) ->
        if newAssignments
          _redraw scope.dataPoints, scope.means, newAssignments

      console.log 'appKmeans directive linked'
]
