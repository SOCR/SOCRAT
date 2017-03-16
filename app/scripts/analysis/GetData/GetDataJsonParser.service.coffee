'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: GetDataJsonParser
  @desc: jsonParser parses the json url input by the user.
  @depends : $http
###

module.exports = class GetDataJsonParser extends BaseService
  @inject '$http'

  initialize: ->

  parse: (opts) ->

    return null if not opts?

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
            return {}

          # generate titles and references
          count data[1][0]
          # format data
          for c in _col
            _column.push
              data: c
          # return object

          data: data[1]
          columns: _column
          colHeaders: _col
          purpose: 'json'

      else
        cb = (data, status) ->
          return data

    # make the call using the cb we just created
    @$http.jsonp(
      opts.url
    )
    .success((data, status) ->
      formattedData = cb data, status
    )
    .error((err) ->
      throw err
    )

