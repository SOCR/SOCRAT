'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsWordCloud extends BaseService
  @inject '$q',
    '$stateParams',
    'app_analysis_charts_dataTransform',
    'app_analysis_charts_list',
    'app_analysis_charts_sendData',
    'app_analysis_charts_checkTime',
    'app_analysis_charts_dataService',
    'app_analysis_charts_msgService'

  initialize: ->
    @msgService = @app_analysis_charts_msgService
    @dataService = @app_analysis_charts_dataService
    @dataTransform = @app_analysis_charts_dataTransform
    @list = @app_analysis_charts_list
    @sendData = @app_analysis_charts_sendData
    @checkTime = @app_analysis_charts_checkTime
    @DATA_TYPES = @dataService.getDataTypes()

    @ve = require 'vega-embed'
    @vt = require 'vega-tooltip/build/vega-tooltip.js'

  drawWordCloud: (data,labels,container, flags) ->

    container.select("#slider").remove()
    container.select("#maxbins").remove()

    content = if flags.text then [flags.text] else data
    startAngle = if flags.startAngle then flags.startAngle else 0
    endAngle = if flags.endAngle then flags.endAngle else 90
    orientations = if flags.orientations then flags.orientations else 1

    vlSpec = {
      "$schema": "https://vega.github.io/schema/vega/v4.json",
      "width": 800,
      "height": 400,
      "padding": 0,
      "data": [
        {
          "name": "table",
          "values": content,
          "transform": [
            {
              "type": "countpattern",
              "field": "data",
              "case": "upper",
              "pattern": "[\\w']{3,}",
              "stopwords": "(i|me|my|myself|we|us|our|ours|ourselves|you|your|yours|yourself|yourselves|he|him|his|himself|she|her|hers|herself|it|its|itself|they|them|their|theirs|themselves|what|which|who|whom|whose|this|that|these|those|am|is|are|was|were|be|been|being|have|has|had|having|do|does|did|doing|will|would|should|can|could|ought|i'm|you're|he's|she's|it's|we're|they're|i've|you've|we've|they've|i'd|you'd|he'd|she'd|we'd|they'd|i'll|you'll|he'll|she'll|we'll|they'll|isn't|aren't|wasn't|weren't|hasn't|haven't|hadn't|doesn't|don't|didn't|won't|wouldn't|shan't|shouldn't|can't|cannot|couldn't|mustn't|let's|that's|who's|what's|here's|there's|when's|where's|why's|how's|a|an|the|and|but|if|or|because|as|until|while|of|at|by|for|with|about|against|between|into|through|during|before|after|above|below|to|from|up|upon|down|in|out|on|off|over|under|again|further|then|once|here|there|when|where|why|how|all|any|both|each|few|more|most|other|some|such|no|nor|not|only|own|same|so|than|too|very|say|says|said|shall)"
            },
            {
              "type": "formula", "as": "angle",
              "expr": "['#{startAngle}', '#{endAngle}'][~~(random() * '#{orientations}')]"
            },
            {
              "type": "formula", "as": "weight",
              "expr": "if(datum.text=='justplaceholder', 600, 300)"
            }
          ]
        }
      ],

      "scales": [
        {
          "name": "color",
          "type": "ordinal",
          "range": ["#d5a928", "#652c90", "#939597"]
        }
      ],

      "marks": [
        {
          "type": "text",
          "from": {"data": "table"},
          "encode": {
            "enter": {
              "text": {"field": "text"},
              "align": {"value": "center"},
              "baseline": {"value": "alphabetic"},
              "fill": {"scale": "color", "field": "text"}
            },
            "update": {
              "fillOpacity": {"value": 1}
            },
            "hover": {
              "fillOpacity": {"value": 0.5}
            }
          },
          "transform": [
            {
              "type": "wordcloud",
              "size": [800, 400],
              "text": {"field": "text"},
              "rotate": {"field": "datum.angle"},
              "font": "Helvetica Neue, Arial",
              "fontSize": {"field": "datum.count"},
              "fontWeight": {"field": "datum.weight"},
              "fontSizeRange": [12, 56],
              "padding": 2
            }
          ]
        }
      ]
    }

    opt =
      "actions": {export: true, source: false, editor: false}

    @ve('#vis', vlSpec, opt, (error, result) -> return).then((result) =>
      return
    )

