'use strict'

###
  @name BaseCtrl
  @desc Base class for Angular controllers
###

module.exports = class BaseCtrl

  @register: (module, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    module.controller name, @

  @inject: (annotations...) ->
    ANNOTATION_REG = /^(\S+)(\s+as\s+(\w+))?$/

    @annotations = annotations.map (annotation) ->
      match = annotation.match(ANNOTATION_REG)
      name: match[1], identifier: match[3] or match[1]

    @$inject = @annotations.map (annotation) -> annotation.name

  constructor: (dependencies...) ->
    if dependencies.length
      for annotation, index in @constructor.annotations
        @[annotation.identifier] = dependencies[index]

      @initialize?()
