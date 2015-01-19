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
          sumColsVar = jStat.sum matrix.variance()
          rowTotalsVar = jStat.variance matrix.transpose().sum()
          cAlpha = (k / (k - 1)) * (1 - sumColsVar / rowTotalsVar)

          sb.publish
            msg: 'calculated'
            data: cAlpha
            msgScope: ['instrPerfEval']

    setSb: _setSb
])

#.factory('cronbachsAlpha', [
#    () ->
#
#      _calc = (data) ->
#        matrix = jStat(data)
#
#      cronbachsAlpha: _calc
#  ])
