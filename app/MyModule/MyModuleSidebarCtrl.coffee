'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleSidebarCtrl extends BaseCtrl
  @inject 'myModuleMyService'

  initialize: ->
    @message = @myModuleMyService.getSidebarMessage()
