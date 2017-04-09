'use strict'

module.exports = class AppMessageMap
  constructor: () ->
    @_msgMap = [

      msgFrom: 'saveData'
      scopeFrom: ['app_analysis_getData', 'app_analysis_dataWrangler']
      msgTo: 'save table'
      scopeTo: ['app_analysis_database']
    ,
      msgFrom: 'infer data types'
      scopeFrom: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_reliability'
      ]
<<<<<<< HEAD
      msgTo: 'infer all types'
      scopeTo: ['app_analysis_datalib']
    ,
      msgFrom: 'all types inferred'
=======
      msgTo: 'type.inferAll'
      scopeTo: ['app_analysis_datalib']
    ,
      msgFrom: 'type.inferAll_res'
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      scopeFrom: ['app_analysis_datalib']
      msgTo: 'data types inferred'
      scopeTo: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_reliability'
      ]
    #    ,
    #      msgFrom: 'upload csv'
    #      scopeFrom: ['getData']
    #      msgTo: 'upload csv'
    #      scopeTo: ['app.utils.importer']
#    ,
    # TODO: make message mapping dynamic #SOCRFW-151
#      msgFrom: 'get table'
#      scopeFrom: ['instrPerfEval']
#      msgTo: 'get table'
#      scopeTo: ['app_analysis_database']
#    ,
#      msgFrom: 'take table'
#      scopeFrom: ['app_analysis_database']
#      msgTo: 'take table'
#      scopeTo: ['instrPerfEval']
    ,
      msgFrom: 'getData'
      scopeFrom: ['app_analysis_cluster',
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_charts',
<<<<<<< HEAD
        'app_analysis_reliability',
         'socrat_analysis_module'
=======
        'app_analysis_reliability'
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
      ]
      msgTo: 'get table'
      scopeTo: ['app_analysis_database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['app_analysis_database']
      msgTo: 'takeTable'
      scopeTo: ['app_analysis_cluster',
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_charts',
<<<<<<< HEAD
        'app_analysis_reliability',
        'socrat_analysis_module'
      ]
    ,
      msgFrom:'mymodule:getData'
      scopeFrom:['socrat_analysis_module']
      msgTo :['bastbase : getData']
      scopeTo : ['socrat_analysis_database']
    ,
      msgFrom:'database:receiveData'
      scopeFrom:['socrat_analysis_database']
      msgTo :['bastbase : receiveData']
      scopeTo : ['socrat_analysis_mymodule']
=======
        'app_analysis_reliability'
      ]
>>>>>>> 1ad2735a1dd1c63c6a42fd4d91449722cd07f1fe
    ]

  getMap: ->
    @_msgMap
