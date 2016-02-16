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
  '$rootScope'
  ($rootScope) ->
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

    # wrapper function for controller communications
    _broadcast = (msg, data) ->
      $rootScope.$broadcast msg, data

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
    broadcast: _broadcast
])

.controller('kMeansMainCtrl', [
  'app_analysis_kMeans_manager'
  'app_analysis_kMeans_calculator'
  '$scope'
  '$timeout'
  (msgManager, kMeans, $scope, $timeout) ->
    console.log 'kMeansMainCtrl executed'

    _dataPoints = null
    _means = null
    _assignments = null
    $scope.showresults = off
    $scope.avgAccuracy = ''
    $scope.accs = {}

    prettifyArrayOutput = (arr) ->
      if arr?
        arr = arr.map (x) -> x.toFixed 3
        '[' + arr.toString().split(',').join('; ') + ']'

    showResults = (accuracy) ->
      if Object.keys(accuracy).length isnt 0
        $scope.avgAccuracy = accuracy.average.toFixed(2)
        delete accuracy.average
        $scope.accs = accuracy
        $scope.showresults = on

    updateChartData = () ->
      $scope.dataPoints = _dataPoints
      $scope.means = _means
      $scope.assignments = _assignments

    _update = (dataPoints, means=null, assignments=null) ->
      $scope.showresults = off if $scope.showresults is on
      _dataPoints = dataPoints
      _means = means if means
      _assignments = assignments if assignments
      # safe enforce $scope.$digest to activate directive watchers
      $timeout updateChartData

    _finish = (results=null) ->
      msgManager.broadcast 'kmeans:done', results
      showResults results

    graph =
      update: _update
      showResults: _finish

    updateChartData()
    kMeans.setGraph graph
])

.controller('kMeansSidebarCtrl', [
  'app_analysis_kMeans_manager'
  'app_analysis_kMeans_calculator'
  '$scope'
  '$stateParams'
  '$q'
  '$timeout'
  (msgManager, kmeans, $scope, $stateParams, $q, $timeout) ->
    console.log 'kMeansSidebarCtrl executed'

    DEFAULT_CONTROL_VALUES =
      k: 2
      distance: 'Euclidean'
      initialisation: 'Forgy'
      labelson: true
      wholedataseton: true
      accuracyon: false

    # set initial values for sidebar controls
    initSidebarControls = (initControlValues) ->

      params = kmeans.getParameters()
      $scope.ks = [params.minK..params.maxK]
      $scope.distances = params.distances
      $scope.inits = params.initMethods

      $scope.cols = []
      $scope.kmeanson = on
      $scope.running = 'hidden'
      $scope.uniqueLabels =
        labelCol: null
        num: null

      $scope.k = initControlValues.k if initControlValues.k in $scope.ks
      $scope.dist = initControlValues.distance if initControlValues.distance in $scope.distances
      $scope.initMethod = initControlValues.initialisation if initControlValues.initialisation in $scope.inits
      $scope.labelson = initControlValues.labelson
      $scope.wholedataseton = initControlValues.wholedataseton
      $scope.accuracyon = initControlValues.accuracyon

    # update data-driven sidebar controls
    updateSidebarControls = (data) ->
      $scope.cols = data.header
      [firstCol, secondCol, ..., lastCol] = $scope.cols
      $scope.xCol = firstCol
      $scope.yCol = secondCol
      $scope.labelCol = lastCol
      $scope.kmeanson = off
      if $scope.labelson
        $scope.numUniqueLabels = detectKValue data

    setDetectedKValue = (detectedK) ->
      if detectedK.num <= 10
        $scope.uniqueLabels = detectedK
        $scope.k = detectedK.num
        # TODO: add success messages
      else
        # TODO: create popup with warning message
        console.log 'KMEANS: k is more than 10'

    detectKValue = (data) ->
      # extra check that labels are on
      if $scope.labelson
        labelCol = data.header.indexOf $scope.labelCol
        labels = (row[labelCol] for row in data.data)
        uniqueLabels = labels.filter (x, i, a) -> i is a.indexOf x
        uniqueLabels =
          labelCol: $scope.labelCol
          num: uniqueLabels.length

    # get requested columns from data
    parseDataForKMeans = (data) ->
      xCol = data.header.indexOf $scope.xCol
      yCol = data.header.indexOf $scope.yCol

      # if usage of labels is on
      if $scope.labelson
        labelCol = data.header.indexOf $scope.labelCol
        labels = (row[labelCol] for row in data.data)
      else
        labels = null

      # if clustering on the whole dataset is on
      if $scope.wholedataseton
        rawData =
        if labels
          data = (row.filter((el, idx) -> idx isnt labelCol) for row in data.data)
      else
        # get data for 2 chosen columns
        data = ([row[xCol], row[yCol]] for row in data.data)

      # re-check if possible to compute accuracy
      if $scope.labelson and $scope.k is $scope.numUniqueLabels.num and $scope.accuracyon
        acc = on

      obj =
        data: data
        labels: labels
        xCol: xCol
        yCol: yCol
        acc: acc

    # call k-means service with parsed data and current controls values
    callKMeans = (data) ->
      $scope.kmeanson = on
      $scope.running = 'spinning'
      $scope.$on 'kmeans:done', (event, results) ->
        # use timeout to call $digest
        $timeout ->
          $scope.kmeanson = off
          $scope.running = 'hidden'
      kmeans.run data, $scope.k, $scope.dist, $scope.initMethod

    # subscribe for incoming message with data
    subscribeForData = ->
      token = sb.subscribe
        msg: 'take data'
        msgScope: ['kMeans']
        listener: (msg, data) ->
          updateSidebarControls(data)
          $scope.detectKValue = ->
            detectedK = detectKValue data
            setDetectedKValue detectedK
          $scope.run = ->
            _data = parseDataForKMeans data
            callKMeans _data

    # ask core for data
    sendDataRequest = (deferred, token) ->
      sb.publish
        msg: 'get data'
        msgScope: ['kMeans']
        callback: -> sb.unsubscribe token
        data:
          tableName: $stateParams.projectId + ':' + $stateParams.forkId
          promise: deferred

    sb = msgManager.getSb()
    deferred = $q.defer()
    initSidebarControls DEFAULT_CONTROL_VALUES
    token = subscribeForData()
    sendDataRequest(deferred, token)
])

.factory('app_analysis_kMeans_calculator', [
  () ->

    _graph = null
    _computeAcc = off
    _clusterWholeDataset = off
    _xCol = null
    _yCol = null
    _maxIter = 20
    _minK = 2
    _maxK = 10
    _distances = ['Euclidean', 'Mahalanobis', 'Manhattan', 'Maximum']
    _initMethods = ['Forgy', 'Random Partition']

    _getParameters = ->
      minK: _minK
      maxK: _maxK
      distances: _distances
      initMethods: _initMethods

    _setGraph = (graph) ->
      _graph = graph

    _updateGraph = (data, centroids=null, labels=null) ->
      # update graph with 2D projection data
      if _clusterWholeDataset
        data = ([row[_xCol], row[_yCol]] for row in data)
        if centroids
          centroids = ([centroid[_xCol], centroid[_yCol]] for centroid in centroids)
      _graph.update data, centroids, labels

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
          reportAccuracy labels, trueLabels, uniqueLabels

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

    _init = (obj, k, distanceType, initMethod) ->

      labels = obj.labels

      if obj.data[0].length > 2
        _clusterWholeDataset = on
        _xCol = obj.xCol
        _yCol = obj.yCol
      else
        _clusterWholeDataset = off

      data = (row.map(Number) for row in obj.data)

      k = Number k
      console.log 'K: ' + k

      if labels
        uniqueLabels = _getUniqueLabels(labels)
        # compute accuracy only when # of clusters is equal to number of unique labels
#        _computeAcc = if uniqueLabels.length is k then on else off
        _computeAcc = obj.acc
      else
        uniqueLabels = [0..k-1]
        _computeAcc = off

      distanceType = distanceType.toLowerCase()
      initMethod = initMethod.toLowerCase()

      _updateGraph data

      if initMethod is 'forgy'
        centroids = _initCentroids data, k
        initLabels = _assignSamples data, centroids, 'euclidean'
      else
        initLabels = _initLabels data.length - 1, k
        centroids = _updateMeans data, uniqueLabels, initLabels

      _updateGraph data, centroids.map((x) -> x.val), initLabels

      console.log 'Starting K-Means'
      _runKMeans data, k, _maxIter, centroids, distanceType, uniqueLabels, labels

    run: _init
    setGraph: _setGraph
    getParameters: _getParameters
  ])

.directive 'appKmeans', [
  '$parse'
  ($parse) ->
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
        _meanLayer.selectAll('.meanDots').remove()
        _meanLayer.selectAll('.assignmentLines').remove()

        pointDots = _graph.selectAll('.pointDots').data(dataPoints)
        pointDots.enter().append('circle').attr('class','pointDots')
        .attr('r', 3)
        .attr('cx', (d) -> _xScale(d[0]))
        .attr('cy', (d) -> _yScale(d[1]))

        pointDots.transition().duration(100)
        .attr('cx', (d) -> _xScale(d[0]))
        .attr('cy', (d) -> _yScale(d[1]))
        pointDots.exit().remove()

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

      scope.$watch 'dataPoints', (newDataPoints) ->
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
      , on

      scope.$watchCollection 'assignments', (newAssignments) ->
        if newAssignments
          _redraw scope.dataPoints, scope.means, newAssignments

      console.log 'appKmeans directive linked'
]
