'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_dataWrangler_wrangler
  @type: service
  @desc: starts wrangler
###

module.exports = class DataWranglerWrangler extends BaseService
  @inject '$q',
    '$timeout'
    '$stateParams'
    '$rootScope'
    'app_analysis_dataWrangler_msgService'
    'app_analysis_dataWrangler_dataService'
    'app_analysis_dataWrangler_dataAdaptor'

  initialize: () ->
    @msgManager = @app_analysis_dataWrangler_msgService
    @dataService = @app_analysis_dataWrangler_dataService
    @dataAdaptor = @app_analysis_dataWrangler_dataAdaptor
    @DATA_TYPES = @msgManager.getSupportedDataTypes()
    @initial_transforms = []
    @table = []
    @csvData = []
    # TODO: make global?
    @dv = require 'datavore'
    @dw = require 'data-wrangler'

  init: ->
    data = @dataService.getData().then (data) =>
      if data.dataFrame.dataType is @DATA_TYPES.FLAT
        @csvData = @dataAdaptor.toCsvString data.dataFrame
        true
      else
        false

  start: (viewContainers) ->
    @table = @wrangle(viewContainers)

  wrangle: (viewContainers) ->
    # TODO: abstract from using dv directly #SOCRFW-143
    table = @dv.table @csvData

    @initial_transforms = @dw.raw_inference(@csvData).transforms

    @dw.wrangler
      table: table
      initial_transforms: @initial_transforms
      tableContainer: viewContainers.tableContainer
      transformContainer: viewContainers.transformContainer
      previewContainer: viewContainers.previewContainer
      dashboardContainer: viewContainers.dashboardContainer

    table

  saveDataToDb: (data, deferred) ->

    msgEnding = if data.dataType is @DATA_TYPES.FLAT then ' as 2D data table' else ' as hierarchical object'

    @msgManager.broadcast 'app:push notification',
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

    console.log data
    @dataService.saveData @dataService.saveDataMsg,
      -> console.log 'wrangled data saved to db',
      data,
      deferred
      console.log 'bludglasd here be more data'
      console.log data

  saveData: ->

    clearTimeout @timer
    @deferred = @$q.defer()

    @data = @dataAdaptor.toDataFrame @table

    @timer = @$timeout ((data, deferred) => @saveDataToDb(data, deferred))(@data, @deferred), 1000

    true
