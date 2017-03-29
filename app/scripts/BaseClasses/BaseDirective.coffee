'use strict'

###
  @name BaseDirective
  @desc Base class for Angular directives
###

module.exports = class BaseDirective

  @register: (module, name) ->
    name ?= @name || @toString().match(/function\s*(.*?)\(/)?[1]

    module.directive name, ((_selfPtr) ->
      directive = (dependencies...) ->
        new _selfPtr dependencies
      if _selfPtr.annotations?
        directive.$inject = _selfPtr.annotations.map (annotation) -> annotation.name
      directive
    )(@)

  # inject the list of dependencies
  @inject: (annotations...) ->
    ANNOTATION_REG = /^(\S+)(\s+as\s+(\w+))?$/

    # annotations.unshift '$scope' if not '$scope' in args
    @annotations = annotations.map (annotation) ->
      match = annotation.match(ANNOTATION_REG)
      name: match[1], identifier: match[3] or match[1]

  constructor: (dependencies) ->
    if dependencies.length
      for annotation, index in @constructor.annotations
        @[annotation.identifier] = dependencies[index]

    # return an object with directive content defined in child class
    @initialize?()
