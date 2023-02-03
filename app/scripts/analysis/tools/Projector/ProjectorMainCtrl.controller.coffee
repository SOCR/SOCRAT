'use strict'
BaseCtrl = require 'scripts/BaseClasses/BaseController.coffee'
module.exports = class ProjectorMainCtrl extends BaseCtrl
    @inject '$timeout', '$scope', 'app_analysis_projector_dataService', 'app_analysis_projector_msgService'
    initialize: ->
        @text = "Component Demo"
        @hello = ""
        @handleHello = () -> 
            @hello = "hello"
        @msgManager = @app_analysis_projector_msgService
        @dataService = @app_analysis_projector_dataService
        @data_y = null
        @data = "1\t1\n2\t2"
        debugger
        console.log(@dataService.getData())
        @dataService.getData().then (data) =>
            console.log(data.dataFrame.data)
            dataStr = ""
            i = 0
            while i < data.dataFrame.data.length
                j = 0
                while j < data.dataFrame.data[i].length
                    if data.dataFrame.data[i][j]
                        dataStr += data.dataFrame.data[i][j]
                        if j < data.dataFrame.data[i].length - 1
                            dataStr += '\t'
                        j++
                if i < data.dataFrame.data.length - 1
                    dataStr += '\n'
                i++
            @data = dataStr
            projector = document.createElement('vz-projector-app')
            projector.setAttribute("serving-mode", "demo")
            projector.setAttribute("projector-config-json-path", "standalone_projector_config.json")
            projector.setAttribute("data-input", dataStr)
            document.getElementById('chart').appendChild(projector)
        true