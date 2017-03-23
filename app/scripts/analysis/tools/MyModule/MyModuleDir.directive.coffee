'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ClusterVizDir extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<dev></dev>"
    @replace = true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>

      MARGIN_LEFT = 40
      MARGIN_TOP = 20

      
