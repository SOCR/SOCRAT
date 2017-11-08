'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class MyModuleVizDir extends BaseDirective
  initialize: ->
    @restrict = 'AECM'
    @template = "<p>{{mainArea.data_from_db}}</p>"
    @replace = true
