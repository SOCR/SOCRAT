'use strict'

###
# @name Core
# @desc Class for registering and starting modules
###
class Core
  constructor: (@eventMngr, @Sandbox, @errorMngr, @utils) ->
    console.log 'CORE CONSTRUCT'

# inject dependencies
Core.$inject = [
  'app_eventMngr'
  'app_sandbox'
  'app_errorMngr'
  'app_utils'
]

# create module and service
angular.module 'app_core', []
  .service 'app_core_service', Core
