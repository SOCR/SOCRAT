'use strict'

BaseModuleStandardizationService = require 'scripts/BaseClasses/BaseModuleStandardizationService.coffee'
module.exports = class MyModuleStandardizationService extends BaseModuleStandardizationService
  initialize: () ->
  	@name = 'Standardization'
  	