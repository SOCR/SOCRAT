'use strict'

ModuleInitService = require 'scripts/BaseClasses/BaseModuleInitService.coffee'

module.exports = class MyModuleMyService extends ModuleInitService
  @inject 'myModule_dataService', '$timeout', 'myModule_msgService'

  initialize: ->
    @message = ''
    @DATA_TYPES = @myModule_msgService.getSupportedDataTypes()
    @data = [1,1,2,3,4]

  getData: -> @data

  getUniqueCount: (cb) =>
    @myModule_dataService.countUnique
      data: [1,1,2,3,4]
      dataType: @DATA_TYPES.FLAT,
      (obj) =>
        if obj.dataFrame
          dataFrame = obj.dataFrame
          cb(dataFrame.data)
