'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class SVMDir extends BaseDirective
  @inject 'app_analysis_svm_svmgraph'
  initialize: ->
    @svm = @app_analysis_svm_svmgraph
    @restrict = 'E'
    @template = "<div id='vis' class='graph-container' style='overflow:auto; height: 600px'></div>"

    @link = (scope) =>
        scope.$watch 'mainArea.dataPoints', (dataP) =>
        #data = newChartData.dataPoints
        data = []
        @svm.drawSVM(data)
         