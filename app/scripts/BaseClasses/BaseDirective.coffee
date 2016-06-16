'use strict'

###
  @name BaseDirective
  @desc Base class for Angular directives
###

module.exports = class BaseDirective

  @register: (module, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    module.directive name, @

  # inject the list of dependencies
  @inject: (annotations...) ->
    ANNOTATION_REG = /^(\S+)(\s+as\s+(\w+))?$/

    # annotations.unshift '$scope' if not '$scope' in args
    @annotations = annotations.map (annotation) ->
      match = annotation.match(ANNOTATION_REG)
      name: match[1], identifier: match[3] or match[1]

    @$inject = @annotations.map (annotation) -> annotation.name

  constructor: (dependencies...) ->
    console.log 12313
    console.log 12313
    console.log 12313
    console.log 12313
    if dependencies.length
      for annotation, index in @constructor.annotations
        @[annotation.identifier] = dependencies[index]

    @initialize?()
