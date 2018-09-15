'use strict'
# import base init service class
BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'
# export custom init service class
module.exports = class ModelerInitService extends BaseModuleInitService
  # requires injection of message service as a dependency
  @inject 'app_analysis_modeler_msgService'
  # entry point function:
  initialize: ->
# this renaming is required for initialization!
    @msgService = @app_analysis_modeler_msgService
    # required method call to initiate module messaging interface
    @setMsgList()
