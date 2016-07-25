'use strict'

###
  @name Module
  @desc Base class for SOCRAT module prototyping
###

module.exports = class Module

  constructor: (options) ->
    {@id = null, @components = @defaultComponents, @state = @defaultState, @deps = []} = options

    module = angular.module @id, @deps unless !@id?

  @defaultComponents =
    services:
      initService: null
      messageService: null
    controllers: []
    directives: []
    runBlock: null

  @defaultState =
    id: null
    url: null
    views:
      main:
        template: null
      sidebar:
        template: null
