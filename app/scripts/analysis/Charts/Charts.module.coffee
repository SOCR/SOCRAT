'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'

module.exports = charts = new Module

# module id for registration
  id: 'app_analysis_charts'

# module components
  components:
    services:
      'app_analysis_charts_initService': require 'scripts/analysis/Charts/ChartsInit.service.coffee'
      'app_analysis_charts_msgService': require 'scripts/analysis/Charts/ChartsMsgService.service.coffee'
      'app_analysis_charts_dataService': require 'scripts/analysis/Charts/ChartsDataService.service.coffee'
      'app_analysis_charts_areaChart': require 'scripts/analysis/Charts/ChartsAreaChart.service.coffee'
      'app_analysis_charts_barChart': require 'scripts/analysis/Charts/ChartsBarChart.service.coffee'
      'app_analysis_charts_trellisChart': require 'scripts/analysis/Charts/ChartsTrellisChart.service.coffee'
      'app_analysis_charts_binnedHeatmap' : require 'scripts/analysis/Charts/ChartsBinnedHeatmapChart.service.coffee'
      'app_analysis_charts_bivariateLineChart': require 'scripts/analysis/Charts/ChartsBivariateLineChart.service.coffee'
      'app_analysis_charts_bubbleChart': require 'scripts/analysis/Charts/ChartsBubbleChart.service.coffee'
      'app_analysis_charts_histogram': require 'scripts/analysis/Charts/ChartsHistogram.service.coffee'
      'app_analysis_charts_lineChart': require 'scripts/analysis/Charts/ChartsLineChart.service.coffee'
      'app_analysis_charts_normalChart': require 'scripts/analysis/Charts/ChartsNormalChart.service.coffee'
      'app_analysis_charts_pieChart': require 'scripts/analysis/Charts/ChartsPieChart.service.coffee'
      'app_analysis_charts_scatterPlot': require 'scripts/analysis/Charts/ChartsScatterPlot.service.coffee'
      'app_analysis_charts_streamChart': require 'scripts/analysis/Charts/ChartsStreamChart.service.coffee'
      'app_analysis_charts_stripPlot' : require 'scripts/analysis/Charts/ChartsStripPlot.service.coffee'
      'app_analysis_charts_stackedBar': require 'scripts/analysis/Charts/ChartsStackedBar.service.coffee'
      'app_analysis_charts_tilfordTree': require 'scripts/analysis/Charts/ChartsTilfordTree.service.coffee'
      'app_analysis_charts_treemap': require 'scripts/analysis/Charts/ChartsTreemap.service.coffee'
      'app_analysis_charts_list': require 'scripts/analysis/Charts/ChartsList.service.coffee'
      'app_analysis_charts_sendData': require 'scripts/analysis/Charts/ChartsSendData.service.coffee'
      'app_analysis_charts_dataTransform': require 'scripts/analysis/Charts/ChartsDataTransform.service.coffee'
      'app_analysis_charts_checkTime': require 'scripts/analysis/Charts/ChartsCheckTime.service.coffee'
      'app_analysis_charts_areaTrellisChart': require 'scripts/analysis/Charts/ChartsAreaTrellisChart.service.coffee'
      'app_analysis_charts_tukeyBoxPlot': require 'scripts/analysis/Charts/ChartsTukeyBoxPlot.service.coffee'
      'app_analysis_charts_scatterMatrix': require 'scripts/analysis/Charts/ChartsScatterMatrix.service.coffee'
      'app_analysis_charts_divergingStackedBar': require 'scripts/analysis/Charts/ChartsDivergingStackedBar.service.coffee'
      'app_analysis_charts_rangedDotPlot': require 'scripts/analysis/Charts/ChartsRangedDotPlot.service.coffee'
      'app_analysis_charts_bulletChart': require 'scripts/analysis/Charts/ChartsBulletChart.service.coffee'
      'app_analysis_charts_wordCloud': require 'scripts/analysis/Charts/ChartsWordCloud.service.coffee'
      'app_analysis_charts_sunburst': require 'scripts/analysis/Charts/ChartsSunburst.service.coffee'
      'app_analysis_charts_cumulative': require 'scripts/analysis/Charts/ChartsCumulativeFrequency.service.coffee'
      'app_analysis_charts_residual': require 'scripts/analysis/Charts/ChartsResidual.service.coffee'
      'app_analysis_charts_mapChart': require 'scripts/analysis/Charts/ChartsMapChart.service.coffee'
      'app_analysis_charts_parallelCoordinates': require 'scripts/analysis/Charts/ChartsParallelCoordinates.service.coffee'

    controllers:
      'ChartsSidebarCtrl': require 'scripts/analysis/Charts/ChartsSidebarCtrl.controller.coffee'
      'ChartsMainCtrl': require 'scripts/analysis/Charts/ChartsMainCtrl.controller.coffee'

    directives:
      'd3charts': require 'scripts/analysis/Charts/ChartsDir.directive.coffee'

# module state config
  state:
# module name to show in UI
    name: 'Charts'
    url: '/charts'
    mainTemplate: require 'partials/analysis/Charts/main.jade'
    sidebarTemplate: require 'partials/analysis/Charts/sidebar.jade'
