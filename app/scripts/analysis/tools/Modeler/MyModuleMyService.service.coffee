'use strict'
# import base class for data service
BaseService = require 'scripts/BaseClasses/BaseService.coffee'
# export custom data service class
module.exports = class MyModuleMyService extends BaseService
  initialize: () ->
  showAlert: ->
    alert 'I pray Thee, O Developer, that I may be beautiful within.'
