'use strict'

qualRobEst = angular.module('app_qualRobEst', [])

.factory('qualRobEst', [
  'qualRobEst_manager'
  (manager) ->
    (sb) ->

      manager.setSb sb unless !sb?

      _msgList =
        outgoing: ['numbers added']
        incoming: ['add numbers']
        scope: ['qualRobEst']

      init: (opt) ->
        console.log 'qualRobEst init invoked'

      destroy: () ->

      msgList: _msgList
])

.factory('qualRobEst_manager', [
  'estimator'
  (estimator) ->
    _sb = null

    _setSb = (sb) ->
      _sb = sb
      estimator.setSb sb

    _getSb = () ->
      _sb

    getSb: _getSb
    setSb: _setSb
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
