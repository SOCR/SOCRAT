'use strict'


BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ModelerDir extends BaseDirective

  initialize: ->
    @normal = @socrat_modeler_distribution_normal
    @restrict = 'E'
    @template = "<div class='graph-container' style='height: 600px'></div>"




    @link = (scope, elem, attr) =>
      margin = {top: 10, right: 40, bottom: 50, left:80}
      width = 750 - margin.left - margin.right
      height = 500 - margin.top - margin.bottom
      svg = null
      data = null
      _graph = null
      container = null
      gdata = null
      ranges = null


