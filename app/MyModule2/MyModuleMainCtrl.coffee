'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'myModuleMyService', 'myModule_msgService'

  initialize: ->
    @message = @myModuleMyService.getMainMessage()
