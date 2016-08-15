'use strict'

module.exports = class AppMessageMap
  constructor: () ->
    @_msgMap = [
    #      msgFrom: 'add numbers'
    #      scopeFrom: ['qualRobEstView']
    #      msgTo: 'add numbers'
    #      scopeTo: ['qualRobEst']
    #    ,
    #      msgFrom: 'numbers added'
    #      scopeFrom: ['qualRobEst']
    #      msgTo: 'numbers added'
    #      scopeTo: ['qualRobEstView']
    #    ,
      msgFrom: 'save data'
      scopeFrom: ['app_analysis_getData', 'app_analysis_dataWrangler']
      msgTo: 'save table'
      scopeTo: ['app_analysis_database']
    #    ,
    #      msgFrom:'table saved'
    #      scopeFrom: ['database']
    #      msgTo: '234'
    #      scopeTo: ['qualRobEst']
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
    #    ,
    #      msgFrom: 'get data'
    #      scopeFrom: ['kMeans']
    #      msgTo: 'get table'
    #      scopeTo: ['database']
    #    ,
    #      msgFrom: 'take table'
    #      scopeFrom: ['database']
    #      msgTo: 'take data'
    #      scopeTo: ['kMeans']
    ,
      msgFrom: 'getData'
      scopeFrom: ['app_analysis_cluster']
      msgTo: 'get table'
      scopeTo: ['app_analysis_database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['app_analysis_database']
      msgTo: 'take table'
      scopeTo: ['app_analysis_cluster']
    #    ,
    #      msgFrom: 'get data'
    #      scopeFrom: ['spectrClustr']
    #      msgTo: 'get table'
    #      scopeTo: ['database']
    #    ,
    #      msgFrom: 'take table'
    #      scopeFrom: ['database']
    #      msgTo: 'take data'
    #      scopeTo: ['spectrClustr']
    ,
      msgFrom: 'get data'
      scopeFrom: ['app_analysis_dataWrangler']
      msgTo: 'get table'
      scopeTo: ['app_analysis_database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['app_analysis_database']
      msgTo: 'wrangle data'
      scopeTo: ['app_analysis_dataWrangler']
    ,
      msgFrom: 'get table'
      scopeFrom: ['app_analysis_charts']
      msgTo: 'get table'
      scopeTo: ['app_analysis_database']
    ,
      msgFrom: 'take table'
      scopeFrom: ['app_analysis_database']
      msgTo: 'take table'
      scopeTo: ['app_analysis_charts']

    ]

  getMap: ->
    @_msgMap
