'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: GetDataJsonParser
  @desc: jsonParser parses the json url input by the user.
  @deps : $q, $rootscope, $http
###

module.exports = class GetDataJsonParser extends BaseService
  @inject '$q', '$rootScope', '$http'

  initialize: ->

  parse: (opts) ->

    return null if not opts?

    # test json : https://graph.facebook.com/search?q=ucla
    deferred = @$q.defer()
    console.log deferred.promise

    switch opts.type

      when 'worldBank'
        # create the callback
        cb = (data, status) ->
          # obj[0] will contain meta deta
          # obj[1] will contain array
          _col = []
          _column = []
          tree = []

          count = (obj) ->
            try
              if typeof obj is 'object' and obj isnt null
                for key in Object.keys obj
                  tree.push key
                  count obj[key]
                  tree.pop()
              else
                _col.push tree.join('.')
              return _col
            catch e
              console.log e.message
            return true

          # generate titles and references
          count data[1][0]
          # format data
          for c in _col
            _column.push
              data: c

          # return object
          data: data
          columns: _column
          columnHeader: _col
          # purpose is helps in pin pointing which
          # handsontable directive to update.
          purpose: 'json'

      else
        #default implementation
        cb = (data, status) ->
          console.log data
          return data

    # using broadcast because msg sent from rootScope
    @$rootScope.$broadcast 'app:push notification',
      initial:
        msg: 'Asking worldbank...'
        type: 'alert-info'
      success:
        msg: 'Successfully loaded data.'
        type: 'alert-success'
      failure:
        msg: 'Error in the call.'
        type: 'alert-error'
      promise: deferred.promise

    # make the call using the cb we just created
    @$http.jsonp(
      opts.url
    )
    .success((data, status) ->
      console.log 'deferred.promise'
      formattedData = cb data, status
      deferred.resolve formattedData
      #$rootScope.$apply()
    )
    .error((data, status) ->
      console.log 'promise rejected'
      deferred.reject 'promise is rejected'
    )

    deferred.promise
