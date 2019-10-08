'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class DimensionReductionDir extends BaseDirective
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

      scope.$watch 'mainArea.receivedLink', (receivedLink) =>
        tensorboard = document.getElementById('src')
        tryNode = document.getElementById('Try')
        tensorboard.src = receivedLink
        newTensorBoard = tensorboard.cloneNode(true)
        tryNode.removeChild(tryNode.childNodes[0])
        tryNode.appendChild(newTensorBoard)

      , on # turn on for complex data structures.
