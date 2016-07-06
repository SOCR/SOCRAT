'use strict'

###
  @name BaseDirective
  @desc Base class for Angular directives
###

module.exports = class BaseDirective

  @directive = (dependencies...) =>
    console.log 12845
    console.log 12845
    new @ dependencies

  @register: (module, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]
    @directive.base = @
    module.directive name, @directive

  # inject the list of dependencies
  @inject: (annotations...) ->
    ANNOTATION_REG = /^(\S+)(\s+as\s+(\w+))?$/

    # annotations.unshift '$scope' if not '$scope' in args
    @annotations = annotations.map (annotation) ->
      match = annotation.match(ANNOTATION_REG)
      name: match[1], identifier: match[3] or match[1]

    @directive.$inject = @annotations.map (annotation) -> annotation.name

  constructor: (dependencies) ->
    console.log 12313
    console.log 12313
    if dependencies.length
      for annotation, index in @constructor.annotations
        @[annotation.identifier] = dependencies[index]

    # return an object with directive content defined in child class
    @initialize?()
