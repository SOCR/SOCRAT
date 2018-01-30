'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class StatsVizDiv extends BaseDirective
  @inject '$parse'

  initialize: ->
    @restrict = 'E'
    @template = "<div id='#twoTestGraph' class='graph'></div>"
    @replace = true # replace the directive element with the output of the template
