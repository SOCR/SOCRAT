'use strict'

###
# @name Module
# @desc Base class for SOCRAT module prototyping
###
module.exports = class Module
  constructor: (options) ->
    defaultComponents =
      services:
        initService: null
        messageService: null
#        dataService: null
      factories: []
      controllers: []
      directives: []

    defaultState =
      id: null
      url: null
      views:
        main:
          template: null
        sidebar:
          template: null

    {@id = null, @components = defaultComponents, @state = defaultState} = options
