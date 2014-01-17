'use strict'

# app.utils module

utils = angular.module('app.utils', [])

  .factory 'utils', ->
    _clone = (data) ->
      if data instanceof Array
        copy = (v for v in data)
      else
        copy = {}
        copy[k] = v for k, v of data
      copy

    _installFromTo = (srcObj, resObj) ->
      if typeof resObj is 'object' and typeof srcObj is 'object'
        resObj[k] = v for k, v of srcObj
        true
      else false

    _getArgumentNames = (fn = ->) ->
      args = fn.toString().match ///
          function    # start with 'function'
          [^(]*       # any character but not '('
          \(          # open bracket = '(' character
            ([^)]*)   # any character but not ')'
          \)          # close bracket = ')' character
        ///
      return [] if not args? or (args.length < 2)
      args = args[1]
      args = args.split /\s*,\s*/
      (a for a in args when a.trim() isnt '')

    ### based on RFC 4122, section 4.4 ###
    _getGuid = () ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
        r = Math.random() * 16 | 0
        v = (if c is 'x' then r else (r & 0x3 | 0x8))
        v.toString 16

    _runSeries = (tasks = [], cb = (->), force) ->
      count = tasks.length
      results = []

      return cb? null, results if count is 0

      errors = []

      checkEnd = ->
        count--
        if count is 0
          if (e for e in errors when e?).length > 0
            cb errors, results
          else
            cb null, results

      for t, i in tasks then do (t, i) ->
        next = (err, res...) ->
          if err?
            errors[i] = err
            results[i] = undefined
          else
            results[i] = if res.length < 2 then res[0] else res
          checkEnd()
        try
          t next
        catch e
          next e if force

    _runWaterfall = (tasks, cb) ->
      i = -1
      return cb() if tasks.length is 0

      next = (err, res...) ->
        return cb err if err?
        if ++i is tasks.length
          cb null, res...
        else
          tasks[i] res..., next
      next()

    _doForAll = (args = [], fn, cb)->
      tasks = for a in args then do (a) ->
        (next) ->
          fn a, next
      _runSeries tasks, cb

    clone: _clone
    installFromTo: _installFromTo
    getArgumentNames: _getArgumentNames
    getGuid: _getGuid
    doForAll: _doForAll
    runSeries: _runSeries
    runWaterfall: _runWaterfall