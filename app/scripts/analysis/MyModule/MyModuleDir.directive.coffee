'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class MyModuleDir extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<div></div>" # can change to <p> or <div>
    @replace = true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>

      MARGIN_LEFT = 40
      MARGIN_TOP = 20

      graph = null
      xScale = null
      yScale = null
      color = null
      meanLayer = null
      console.log(elem[0])
      scope.$watch 'mainArea.receivedData', (receivedData) =>
        console.log(receivedData)
        textnode = document.createTextNode(receivedData)
        elem[0].appendChild(textnode)
      , on # turn on for complex data structures.