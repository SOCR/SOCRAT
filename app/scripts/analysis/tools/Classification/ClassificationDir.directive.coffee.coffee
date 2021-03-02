'use strict'

require 'jquery-ui/ui/widgets/slider'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class ClassificationDir extends BaseDirective
  @inject 'app_analysis_classification_classificationgraph'
  initialize: ->
    @classification = @app_analysis_classification_classificationgraph
    @restrict = 'E'
    @template = "<div id='vis' class='graph-container' style='overflow:auto; height: 600px'></div>"

         