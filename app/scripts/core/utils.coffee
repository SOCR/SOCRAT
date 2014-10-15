'use strict'

# app.utils module

utils = angular.module('app_utils', [])

utils.factory 'utils', ->

  _typeIsArray = Array.isArray || (value) -> return {}.toString.call(value) is '[object Array]'

  _installFromTo = (srcObj, resObj) ->
    if typeof resObj is 'object' and typeof srcObj is 'object'
      resObj[k] = v for k, v of srcObj
      true
    else false

  _fnRgx =
    ///
      function    # start with 'function'
      [^(]*       # any character but not '('
      \(          # open bracket = '(' character
        ([^)]*)   # any character but not ')'
      \)          # close bracket = ')' character
    ///

  _argRgx = /([^\s,]+)/g

  _getArgumentNames = (fn) ->
    (fn?.toString().match(_fnRgx)?[1] or '').match(_argRgx) or []

  ### based on RFC 4122, section 4.4 ###
  _generateGuid = () ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = (if c is 'x' then r else (r & 0x3 | 0x8))
      v.toString 16

  # run asynchronous tasks in parallel
  _runParallel = (tasks=[], cb=(->), force) ->
    count   = tasks.length
    results = []

    return cb null, results if count is 0

    errors  = []; hasErr = false

    for t,i in tasks then do (t,i) ->
      next = (err, res...) ->
        if err
          errors[i] = err
          hasErr    = true
          return cb errors, results unless force
        else
          results[i] = if res.length < 2 then res[0] else res
        if --count <= 0
          if hasErr
            cb errors, results
          else
            cb null, results
      try
        t next
      catch e
        next e

  # run asynchronous tasks one after another
  _runSeries = (tasks=[], cb=(->), force) ->
    i = -1
    count   = tasks.length
    results = []
    return cb null, results if count is 0

    errors = []; hasErr = false

    next = (err, res...) ->
      if err
        errors[i] = err
        hasErr    = true
        return cb errors, results unless force
      else
        if i > -1 # first run
          results[i] = if res.length < 2 then res[0] else res
      if ++i >= count
        if hasErr
          cb errors, results
        else
          cb null, results
      else
        try
          tasks[i] next
        catch e
          next e
    next()

  # run asynchronous tasks one after another
  # and pass the argument
  _runWaterfall = (tasks, cb) ->
    i = -1
    return cb() if tasks.length is 0

    next = (err, res...) ->
      return cb err if err?
      if ++i >= tasks.length
        cb null, res...
      else
        tasks[i] res..., next
    next()

  _doForAll = (args=[], fn, cb, force)->
    tasks = for a in args then do (a) -> (next) -> fn a, next
    _runParallel tasks, cb, force

  typeIsArray: _typeIsArray
  installFromTo: _installFromTo
  getArgumentNames: _getArgumentNames
  getGuid: _generateGuid
  doForAll: _doForAll
  runSeries: _runSeries
  runWaterfall: _runWaterfall
  runParallel: _runParallel