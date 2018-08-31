'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

module.exports = class ChartsCheckTime extends BaseService

  initialize: ->

    @formats = [
      "MM/DD/YYYY",
      "M/DD/YYYY",
      "M/D/YYYY",
      "MM/DD/YY",
      "M/DD/YY",
      "M/D/YY",
      "L",
      "l",
      "DD-MMM-YY",
      "D-MMM-YY",
      "DDD-MMM-YYYY"
    ]

  #determines if an array is a date variable
  arrayDate: (array) =>
    for i in [0...array.length] by 1
      return false unless moment(array[i].value, @formats, true).isValid()
    true

  checkData: (data) ->
    data.filter @arrayDate

  checkForTime: (data) ->
    if @checkData(data).length is 0
      return false
    true

  checkTimeChoice: (data) ->
    time = data.map (d) -> d.x
    alert "x is not a time variable" unless arrayDate d3.entries time
