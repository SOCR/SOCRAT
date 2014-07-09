'use strict'

qualRobEst = angular.module('app_analysis_qualRobEst', [])

.factory('app_analysis_qualRobEst_constructor', [
  'app_analysis_qualRobEst_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?
      _msgList = manager.getMsgList()

      init: (opt) ->
        console.log 'qualRobEst init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('app_analysis_qualRobEst_manager', [
  'estimator'
  (estimator) ->
    _sb = null

    _msgList =
      outgoing: ['numbers added']
      incoming: ['add numbers']
      scope: ['qualRobEst']

    _setSb = (sb) ->
      _sb = sb
      estimator.setSb sb

    _getSb = () ->
      _sb

    _getMsgList = () ->
      _msgList

    getSb: _getSb
    setSb: _setSb
    getMsgList: _getMsgList
])

.factory('estimator', [
  () ->
    sb = null

    _setSb = (sb) ->
      sb.subscribe
        msg: 'add numbers'
        listener: (msg, data) ->
          sum = data.a + data.b
          sb.publish
            msg: 'numbers added'
            data: sum
            msgScope: ['qualRobEst']
        msgScope: ['qualRobEst']

    setSb: _setSb
])
