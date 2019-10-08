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
        'app_analysis_reliability',
        'app_analysis_powercalc',
        'app_analysis_stats',
        'app_analysis_classification',
        'app_analysis_modeler'
        'app_analysis_dimReduction',
        'socrat_analysis_myModule'
      ]
      msgTo: 'type.inferAll'
      scopeTo: ['app_analysis_datalib']
    ,
      msgFrom: 'type.inferAll_res'
      scopeFrom: ['app_analysis_datalib']
      msgTo: 'data types inferred'
      scopeTo: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_reliability',
        'app_analysis_powercalc',
        'app_analysis_stats',
        'app_analysis_classification',
        'app_analysis_modeler'
        'app_analysis_dimReduction',
        'socrat_analysis_myModule'
      ]
    ,
      msgFrom: 'data summary'
      scopeFrom: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_reliability',
        'app_analysis_powercalc',
        'app_analysis_classification',
        'app_analysis_stats',
        'socrat_analysis_myModule'
      ]
      msgTo: 'summary'
      scopeTo: ['app_analysis_datalib']
    ,
      msgFrom: 'summary_res'
      scopeFrom: ['app_analysis_datalib']
      msgTo: 'data summary result'
      scopeTo: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_reliability',
        'app_analysis_powercalc',
        'app_analysis_classification',
        'app_analysis_stats',
        'socrat_analysis_myModule'
      ]
    ,
      msgFrom: 'data histogram'
      scopeFrom: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_classification',
        'app_analysis_reliability',
        'socrat_analysis_myModule'
      ]
      msgTo: 'histogram'
      scopeTo: ['app_analysis_datalib']
    ,
      msgFrom: 'histogram_res'
      scopeFrom: ['app_analysis_datalib']
      msgTo: 'data histogram result'
      scopeTo: [
        'app_analysis_getData',
        'app_analysis_dataWrangler',
        'app_analysis_cluster',
        'app_analysis_charts',
        'app_analysis_classification',
        'app_analysis_reliability',
        'socrat_analysis_myModule'
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
        'app_analysis_reliability',
        'app_analysis_powercalc',
        'app_analysis_stats',
        'app_analysis_classification',
        'app_analysis_modeler'
        'app_analysis_dimReduction',
        'socrat_analysis_myModule'
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
        'app_analysis_reliability',
        'app_analysis_powercalc',
        'app_analysis_stats',
        'app_analysis_classification',
        'app_analysis_modeler'
        'app_analysis_dimReduction',
        'socrat_analysis_myModule'
      ]
    ,
      msgFrom: 'getData'
      scopeFrom: ['socrat_analysis_myModule']
      msgTo: 'get table'
      scopeTo: ['app_analysis_database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['app_analysis_database']
      msgTo: 'receiveData'
      scopeTo: ['socrat_analysis_myModule']
    ]

  getMap: ->
    @_msgMap
