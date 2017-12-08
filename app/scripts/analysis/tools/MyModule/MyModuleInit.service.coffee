'use strict'

BaseModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

<<<<<<< HEAD
module.exports = class app_analysis_mymodule_initService extends BaseModuleInitService
=======
module.exports = class MyModuleInitService extends BaseModuleInitService
>>>>>>> master
  @inject 'app_analysis_mymodule_msgService'

  initialize: ->
    @msgService = @app_analysis_mymodule_msgService
    @setMsgList()
