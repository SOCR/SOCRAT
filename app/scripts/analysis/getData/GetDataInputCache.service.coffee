'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_getData_inputCache
  @type: service
  @desc: Caches data. Changes to handsontable is stored here
  and synced after some time. Changes in db is heard and reflected on
  handsontable.
###

module.exports = class GetDataInputCache extends BaseService
  @inject '$q', '$stateParams', '$rootScope', '$timeout', 'app_analysis_getData_manager'

  initialize: () ->
#    @msgManager = @app_analysis_getData_manager
#    @DATA_TYPES = @msgManager.getSupportedDataTypes()
#    @sb = @msgManager.getSb()
    @data = {}
    @timer = null
    @ht = null

  getData: ->
    @data

  saveDataToDb: (data, deferred) ->

    msgEnding = if data.dataType is DATA_TYPES.FLAT then ' as 2D data table' else ' as hierarchical object'

    @$rootScope.$broadcast 'app:push notification',
      initial:
        msg: 'Data is being saved in the database...'
        type: 'alert-info'
      success:
        msg: 'Successfully loaded data into database' + msgEnding
        type: 'alert-success'
      failure:
        msg: 'Error in Database'
        type: 'alert-error'
      promise: deferred.promise

    @sb.publish
      msg: 'save data'
      data:
        dataFrame: data
        tableName: @$stateParams.projectId + ':' + @$stateParams.forkId
        promise: deferred
      msgScope: ['getData']
      callback: ->
        console.log 'handsontable data updated to db'

  setData: (data) ->
    console.log '%c inputCache set called for the project' + @$stateParams.projectId + ':' + @$stateParams.forkId,
      'color:steelblue'

    # TODO: fix checking existance of parameters to default table name #SOCR-140
    if data? or @$stateParams.projectId? or @$stateParams.forkId?
      @data = data unless data is 'edit'

      # clear any previous db update broadcast messages
      clearTimeout @timer
      @deferred = $q.defer()
      @timer = $timeout ((data, deferred) -> _saveDataToDb(data, deferred))(@data, @deferred), 1000
      true

    else
      console.log "no data passed to inputCache"
      false

  pushData: (data) ->
    @ht.loadData data
