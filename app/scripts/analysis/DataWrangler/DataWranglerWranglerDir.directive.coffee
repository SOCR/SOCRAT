'use strict'

require 'jquery-ui-layout'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class DataWranglerWranglerDir extends BaseDirective
  @inject 'app_analysis_dataWrangler_wrangler', 'app_analysis_dataWrangler_msgService', '$timeout'

  initialize: ->
    @wrangler = @app_analysis_dataWrangler_wrangler
    @msgManager = @app_analysis_dataWrangler_msgService

    @restrict = 'E'
    @transclude = true
    @template = require('partials/analysis/DataWrangler/wrangler.jade')()
    @replace = true # replace the directive element with the output of the template

    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, elem, attr) =>
    # useful to identify which handsontable instance to update
      scope.purpose = attr.purpose

      DATA_TYPES = @msgManager.getSupportedDataTypes()

      @$timeout => # check if received dataset is flat
        if scope.mainArea.dataType? and scope.mainArea.dataType is DATA_TYPES.FLAT
          myLayout = $('#dt_example').layout
            north:
              spacing_open: 0
              resizable: false
              slidable: false
              fxName: 'none'
            south:
              spacing_open: 0
              resizable: false
              slidable: false
              fxName: 'none'
            west:
              minSize: 310

          container = $('#table')
          previewContainer = $('#preview')
          transformContainer = $('#transformEditor')
          dashboardContainer = $("#wranglerDashboard")

          @wrangler.start
            tableContainer: container
            transformContainer: transformContainer
            previewContainer: previewContainer
            dashboardContainer: dashboardContainer

          # TODO: find correct programmatic way to invoke header propagation
          # assuming there always is a header in data, propagate it in Wrangler
          $('#table .odd .rowHeader').first().mouseup().mousedown()
          d3.select('div.menu_option.Promote')[0][0].__onmousedown()
          $('div.suggestion.selected').click()
