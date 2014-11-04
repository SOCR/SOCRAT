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
        listener: (msg, data) ->
          sum = data.a + data.b
          sb.publish
            msg: 'calculated'
            data: sum
            msgScope: ['instrPerfEval']
        msgScope: ['instrPerfEval']

    setSb: _setSb
])
