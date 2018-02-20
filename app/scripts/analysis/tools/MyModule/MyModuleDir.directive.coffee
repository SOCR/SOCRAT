'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class MyModuleDir extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<svg width='100%' height='600'></svg>"
    @replace = true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>

      graph = null

      svg = d3.select(elem[0])


