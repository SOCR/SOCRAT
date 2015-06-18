'use strict'

instrPerfEval = angular.module('app_analysis_instrPerfEval', [])

.factory('app_analysis_instrPerfEval_constructor', [
  'app_analysis_instrPerfEval_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'instrPerfEval init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_instrPerfEval_manager', [
  'calculator'
  (calculator) ->
    _sb = null

    _msgList =
      outgoing: ['calculated']
      incoming: ['calculate']
      scope: ['instrPerfEval']

    _setSb = (sb) ->
      _sb = sb
      calculator.setSb sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
])

.factory('calculator', [
  () ->
    sb = null

    _setSb = (sb) ->
      sb.subscribe
        msg: 'calculate'
        msgScope: ['instrPerfEval']
        listener: (msg, obj) ->

          # calculate Cronbach's Alpha
          matrix = jStat obj.data
          k = jStat.cols matrix
          r = jStat.rows matrix

          sumColsVar = jStat.sum matrix.variance()
          rowTotalsVar = jStat.variance matrix.transpose().sum()
          cAlpha = (k / (k - 1)) * (1 - sumColsVar / rowTotalsVar)

          # Split-Half Reliability coefficient
          nGroups = 2
          oddSum = jStat.zeros(1, r)
          evenSum = jStat.zeros(1, r)
          for col in matrix.transpose() by 2
            oddSum = jStat([oddSum, col]).sum()
          for colIdx in [1..k] by 2
            col = jStat.col matrix, colIdx
            evenSum = jStat([evenSum, jStat.transpose(col)]).sum()
          meanOdd = jStat.mean oddSum
          meanEven = jStat.mean evenSum
          rCorrCoef = jStat.corrcoeff(oddSum, evenSum)
          adjRCorrCoef = rCorrCoef * nGroups / ((nGroups - 1) * (rCorrCoef - 1))


          # Calculate confidence intervals
          # TODO: create control for gamma
          gamma = 0.1  # 95%

          # calculate ID confidence intervals
          n = jStat.rows matrix
          alphaCap = 0
          for row in matrix
            centeredRow = jStat.subtract row, jStat.mean row
            alphaCap = alphaCap + jStat.dot centeredRow, centeredRow
          alphaCap = alphaCap / (n - 1)
          omega = 2 * (k - 1) * (1 - alphaCap) / k
          varCapAlphaCap = (k * k * omega) / (n * (k - 1) * (k - 1))

          idIntervalAbsDev = jStat.normal.inv(1 - gamma / 2, 0, 1) * Math.sqrt varCapAlphaCap
          idIntervalLeft = alphaCap - idIntervalAbsDev
          idIntervalRight = alphaCap + idIntervalAbsDev

          # calculate KF confidence intervals
          kfIntervalLeft = 1 - (1 - alphaCap) * Math.exp jStat.normal.inv(1 - gamma / 2, 0, 1) *
              Math.sqrt 2 * k / (n * (k - 1))
          kfIntervalRight = 1 - (1 - alphaCap) * Math.exp -1 * jStat.normal.inv(1 - gamma / 2, 0, 1) *
              Math.sqrt 2 * k / (n * (k - 1))

          #calculate logit confidence intervals
          thetaCap = Math.log alphaCap / (1 - alphaCap)
          varCapThetaCap = varCapAlphaCap * Math.pow 1 / alphaCap + 1 / (1 - alphaCap), 2
          thetaAbsDev = jStat.normal.inv(1 - gamma / 2, 0, 1) * Math.sqrt varCapThetaCap
          thetaIntervalLeft = thetaCap - thetaAbsDev
          thetaIntervalRight = thetaCap + thetaAbsDev
          logitIntervalLeft = Math.exp(thetaIntervalLeft) / (1 + Math.exp thetaIntervalLeft)
          logitIntervalRight = Math.exp(thetaIntervalRight) / (1 + Math.exp thetaIntervalRight)

          _data =
            cronAlpha: cAlpha
            idIntervals: [Math.max(0, idIntervalLeft), Math.min(1, idIntervalRight)]
            kfIntervals: [Math.max(0, kfIntervalLeft), Math.min(1, kfIntervalRight)]
            logitIntervals: [Math.max(0, logitIntervalLeft), Math.min(1, logitIntervalRight)]
            adjRCorrCoef: adjRCorrCoef

          sb.publish
            msg: 'calculated'
            data: cAlpha
            msgScope: ['instrPerfEval']

    setSb: _setSb
])
