'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: GetDataShowState
  @desc: Helps sidebar accordion to keep in sync with the main div
###

module.exports = class GetDataShowState extends BaseService

  initialize: ->
    @obj = null
    @scope = null
    @options = [
        key: "grid",
        label: "Data Grid",
        enabled: true
      ,
        key: "socrData",
        label: "SOCR datasets",
        enabled: true
      ,
        key: "worldBank",
        label:"WORLDBANK datasets",
        enabled: true
      ,
        key: "generate",
        label:"Generate datasets",
        enabled: false
      ,
        key: "jsonParse",
        label:"JSON datasets",
        enabled: true
    ]

  getOptions: ->
    @options

  getOptionKeys: ->
    @options.map (option)->
      option.key

  create: (obj, scope) ->
    if arguments.length is 0
      # return false if no arguments are provided
      return false
    @obj = obj
    @scope = scope

    # create a showState variable and attach it to supplied scope
    @scope.showState = []
    for i in @obj
      @scope.showState[i] = true

    # index is the array key
    set: (index) =>
      if @scope.showState[index]?
        for i in @obj
          if i is index
            @scope.showState[index] = false
          else
            @scope.showState[i] = true
