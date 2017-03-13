'use strict'


BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ModelerDir extends BaseDirective

  initialize: ->
    @normal = @socrat_modeler_distribution_normal


