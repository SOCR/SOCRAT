'use strict'

ModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class MyModuleMyService extends ModuleInitService
  getMainMessage: -> 'This is main area.'
  getSidebarMessage: -> 'This is sidebar.'
