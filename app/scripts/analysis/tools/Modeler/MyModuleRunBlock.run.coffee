'use strict'
module.exports = class MyModuleRunBlock
  constructor: (@module) ->
  register: ->
    @module.run @myModuleRunBlock()
  myModuleRunBlock: ->
    runBlock = (socrat_analysis_mymodule_myService) ->
      socrat_analysis_mymodule_myService.showAlert()
    # inject dependencies for run block
    runBlock.$inject = ['socrat_analysis_mymodule_myService']
    runBlock
