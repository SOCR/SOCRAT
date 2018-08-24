'use strict'

BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'

module.exports = class MyModuleMainCtrl extends BaseCtrl
  @inject 'myModuleMyService'

  initialize: ->
    @message = @myModuleMyService.getMainMessage()
