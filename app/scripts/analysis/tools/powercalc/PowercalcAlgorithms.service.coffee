'use strict'

BaseModuleDataService = require 'scripts/BaseClasses/BaseModuleDataService.coffee'

module.exports = class ClusterAlgorithms extends BaseModuleDataService
  @inject 'app_analysis_powerclac_msgService',
    'app_analysis_powercalc_cfap'

  initialize: ->
    @msgManager = @app_analysis_powercalc_msgService
    @cfap = require 'powercalc'

    @algorithms = [@cfap]

  ############

  getNames: -> @algorithms.map (alg) -> alg.getName()

  getParamsByName: (algName) ->
    (alg.getParams() for alg in @algorithms when algName is alg.getName()).shift()

  getDataTypes: ->
    @msgService.getSupportedDataTypes()























  get_cfap_help: ->
    alert("
      This dialog provides for sample-size determination for estimating a proportion to within a specified margin of error, for either a finite population of specified size, or an infinite population (or sampling with replacement).\n\n
      The confidence interval is of the form p +/- ME, where p is the sample proportion and ME is the margin of error:\n
      ME = z * sqrt{p*(1-p)/(n-1)} (infinite pop)\n
      ME = z * sqrt{p*(1-p)/(n-1)} * sqrt{1 - n/N} (finite pop)\n
      where z is a critical value from the normal distribution, p is the sample proportion, n is the sample size, and N is the population size.\n\n
      USING THE GRAPHICAL INTERFACE\n
      The dialog is designed such that a sample size n is computed whenever you change any of the other input values. If you change n, a new ME is computed (using sigma in place of s in the above formulas).\n\n
      Finite population\n
      If Finite Population is checked, calculations are based on the population size N entered in the adjacent input field.\n
      If the box is unchecked, the \"N\" field is hidden, and calculations are based on an infinite population.\n\n
      Worst case\n
      If Worst case is checked, computations are based on the assumption that the true sample proportion, pi, is .5. If it is not checked, then a pi value other than .5 may be entered in the field to the right of the checkbox.\n\n
      Confidence\n
      Choose the desired confidence coefficient for the ME. This determines the value of z.\n\n
      Margin of Error\n
      Enter the target value of the margin of error here. Note that the actual value achieved after you collect the data will be more or less than this amount, because it will be based on p (estimated from the data) rather than pi.\n\n
      n\n
      Enter the sample size here if you want to see what margin of error is achieved with that size sample. When you change n, it is rounded to the nearest integer; otherwise, n is not rounded\n\n
      Note on sliders\n
      Sliders may be varied by clicking or dragging along the center of the scale. If you drag along at the level of the tick labels, you can change the endpoints of the scale. The small button at the upper right of each slider converts it to and from a keyboard-input mode. In that mode, you can also change the scale endpoints and number of digits displayed.\n\n
      Graphics\n
      A simple graphics facility is available from the Options menu. Enter the variables for the x and y axes, and the range of values for the x variable. More information is available through the graphics dialog's help menu."
    )












    
