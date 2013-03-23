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

    clone: _clone
    installFromTo: _installFromTo
    getArgumentNames: _getArgumentNames
    getGuid: _getGuid