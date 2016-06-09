'use strict'

###
  @name BaseService
  @desc Base class for Angular services
###

module.exports = class BaseService

  @register: (module, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    module.service name, @

  # inject the list of dependencies
  @inject: (annotations...) ->
    ANNOTATION_REG = /^(\S+)(\s+as\s+(\w+))?$/

#    annotations.unshift '$scope' if not '$scope' in args
    @annotations = annotations.map (annotation) ->
      match = annotation.match(ANNOTATION_REG)
      name: match[1], identifier: match[3] or match[1]

    @$inject = @annotations.map (annotation) -> annotation.name

  constructor: (dependencies...) ->
    if dependencies.length
      for annotation, index in @constructor.annotations
        @[annotation.identifier] = dependencies[index]

      @initialize?()
