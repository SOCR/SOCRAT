'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = charts = new Module

# module id for registration
  id: 'app_analysis_charts'

# module components
  components:
    services:
      'app_analysis_charts_initService': require 'scripts/analysis/charts/ChartsInit.service.coffee'
      'app_analysis_charts_msgService': require 'scripts/analysis/charts/ChartsMsgService.service.coffee'
      'app_analysis_charts_areaChart': require 'scripts/analysis/charts/ChartsAreaChart.service.coffee'
      'app_analysis_charts_barChart': require 'scripts/analysis/charts/ChartsBarChart.service.coffee'
      'app_analysis_charts_bivariateLineChart': require 'scripts/analysis/charts/ChartsBivariateLineChart.service.coffee'
      'app_analysis_charts_bubbleChart': require 'scripts/analysis/charts/ChartsBubbleChart.service.coffee'
      'app_analysis_charts_histogram': require 'scripts/analysis/charts/ChartsHistogram.service.coffee'
      'app_analysis_charts_lineChart': require 'scripts/analysis/charts/ChartsLineChart.service.coffee'
      'app_analysis_charts_normalChart': require 'scripts/analysis/charts/ChartsNormalChart.service.coffee'
      'app_analysis_charts_pieChart': require 'scripts/analysis/charts/ChartsPieChart.service.coffee'
      'app_analysis_charts_scatterPlot': require 'scripts/analysis/charts/ChartsScatterPlot.service.coffee'
      'app_analysis_charts_streamChart': require 'scripts/analysis/charts/ChartsStreamChart.service.coffee'
      'app_analysis_charts_stackedBar': require 'scripts/analysis/charts/ChartsStackedBar.service.coffee'
      'app_analysis_charts_tilfordTree': require 'scripts/analysis/charts/ChartsTilfordTree.service.coffee'
      'app_analysis_charts_treemap': require 'scripts/analysis/charts/ChartsTreemap.service.coffee'
      'app_analysis_charts_list': require 'scripts/analysis/charts/ChartsList.service.coffee'
      'app_analysis_charts_sendData': require 'scripts/analysis/charts/ChartsSendData.service.coffee'
      'app_analysis_charts_dataTransform': require 'scripts/analysis/charts/ChartsDataTransform.service.coffee'

    controllers:
      'ChartsSidebarCtrl': require 'scripts/analysis/charts/ChartsSidebarCtrl.controller.coffee'
      'ChartsMainCtrl': require 'scripts/analysis/charts/ChartsMainCtrl.controller.coffee'

    directives: []

# module state config
  state:
# module name to show in UI
    name: 'Charts'
    url: '/charts'
    mainTemplate: require 'partials/analysis/charts/main.jade'
    sidebarTemplate: require 'partials/analysis/charts/sidebar.jade'
