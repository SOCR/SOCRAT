'use strict'
# import base init service class
BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'
# export custom init service class
module.exports = class JiaruiLiuInitService extends BaseModuleInitService
  # requires injection of message service as a dependency
  @inject 'socrat_analysis_JiaruiLiu_msgService'
  # entry point function:
  initialize: ->
    # this renaming is required for initialization!
    @msgService = @socrat_analysis_JiaruiLiu_msgService
    # required method call to initiate module messaging interface
    @setMsgList() 