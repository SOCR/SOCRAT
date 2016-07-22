'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'
require "imports?Handsontable=handsontable/dist/handsontable.full.js!ngHandsontable/dist/ngHandsontable.js"

module.extend = class GetDataHandsontableDirective extends BaseDirective
  @inject 'app_analysis_getData_msgService',
    'app_analysis_getData_inputCache',
    'app_analysis_getData_dataAdaptor',
#    '$exceptionHandler'
    '$timeout'

  initialize: () ->
    @restrict = 'E'
    @transclude = true
    @replace = true
    @template = "<div class='hot-scroll-container' style='height: 300px; width: 100%'></div>"

    @controller = ($scope) ->

    # the link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    #  It is run before the controller
    @link = (scope, elem, attr) ->

      @$timeout ->
        N_SPARE_COLS = 1
        N_SPARE_ROWS = 1
        # from handsontable defaults
        # https://docs.handsontable.com/0.24.1/demo-stretching.html
        DEFAULT_ROW_HEIGHT = 23
        DEFAULT_COL_WIDTH = 47

        # useful to identify which handsontable instance to update
        scope.purpose = attr.purpose

        # retrieves data from handsontable object
        _format = (obj) ->
          data = obj.getData()
          header = obj.getColHeader()
          nCols = obj.countCols()
          nRows = obj.countRows()

          table =
            data: data
            header: header
            nCols: nCols
            nRows: nRows

        scope.update = (evt, arg) ->
          console.log 'handsontable: update called'

          DATA_TYPES = @eventManager.getSupportedDataTypes()

          currHeight = elem[0].offsetHeight
          currWidth = elem[0].offsetWidth

          # check if data is in the right format
          #   if arg? and typeof arg.data is 'object' and typeof arg.columns is 'object'
          if arg? and typeof arg.data is 'object' and arg.dataType is DATA_TYPES.FLAT
            # TODO: not to pass nested data to ht, but save in db
            obj =
              data: arg.data[1]
#              startRows: Object.keys(arg.data[1]).length
#              startCols: arg.columns.length
              colHeaders: arg.columnHeader
              columns: arg.columns
#              minSpareRows: N_SPARE_ROWS
              minSpareCols: N_SPARE_COLS
              allowInsertRow: true
              allowInsertColumn: true
              stretchH: "all"
          else if arg.default is true
            obj =
              data: [
                ['Copy', 'paste', 'your', 'data', 'here']
              ]
              colHeaders: true
              minSpareRows: N_SPARE_ROWS
              minSpareCols: N_SPARE_COLS
              allowInsertRow: true
              allowInsertColumn: true
              rowHeaders: false
          else
            console.log 'handsontable configuration is missing'
#            $exceptionHandler
#              message: 'handsontable configuration is missing'

          obj['change'] = true
          obj['afterChange'] = (change, source) ->
            # saving data to be globally accessible.
            #  only place from where data is saved before DB: inputCache.
            #  onSave, data is picked up from inputCache.
            if source is 'loadData' or 'paste'
              ht = $(this)[0]
              tableData = _format ht
              dataFrame = @dataAdaptor.toDataFrame tableData, N_SPARE_COLS, N_SPARE_ROWS
              inputCache.set dataFrame
              ht.updateSettings
                height: Math.max currHeight, ht.countRows() * DEFAULT_ROW_HEIGHT
                width: Math.max currWidth, ht.countCols() * DEFAULT_COL_WIDTH
            else
              inputCache.set source

          try
            # hook for pushing data changes to handsontable
            # TODO: get rid of tight coupling :-/
            ht = $(elem).handsontable obj
            window['inputCache'] = inputCache.ht = $(ht[0]).data('handsontable')
          catch e
            console.log 'Error: ' + e
#            $exceptionHandler e

        # subscribing to handsontable update
        scope.$on attr.purpose + ':load data to handsontable', scope.update
        console.log 'handsontable directive linked'
