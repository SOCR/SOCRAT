'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class appMyModuleDir extends BaseDirective
  initialize: ->
    @restrict = 'E'
    @template = "<p>{{mainArea.data_from_db}}</p>"
    @replace = true