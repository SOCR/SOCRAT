'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class MyModuleVizDir extends BaseDirective
  @inject '$parse'

  initialize: ->
  	@restrict= 'AECM'
  	@template ="<p>{{mainArea.data}}</p>"
  	@replace= true
 