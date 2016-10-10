'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

###
# @name GetDataDragNDropDir
# @desc Directive for drag-n-drop files into the handsontable
# Inspired by http://buildinternet.com/2013/08/drag-and-drop-file-upload-with-angularjs/
###
module.exports = class GetDataDragNDropDir extends BaseDirective

  initialize: ->
    @restrict = 'A'
    # The link method does the work of setting the directive
    #  up, things like bindings, jquery calls, etc are done in here
    @link = (scope, element, attrs) =>
      # function to prevent default behavior (browser loading image)
      processDragOverOrEnter = (event) ->
        event?.preventDefault()
        if event.dataTransfer
          event.dataTransfer.effectAllowed = 'copy'
        else if event.originalEvent.dataTransfer
          event.originalEvent.dataTransfer.effectAllowed = 'copy'
        false

      validMimeTypes = attrs.getdatadragndrop

      # if the max file size is provided and the size of dropped file is greater than it,
      # it's an invalid file and false is returned
      checkSize = (size) ->
        if attrs.maxFileSize in [undefined, ''] or (size / 1024) / 1024 < attrs.maxFileSize
          true
        else
          alert "File must be smaller than #{attrs.maxFileSize} MB"
          false

      isTypeValid = (type) ->
        if validMimeTypes in [undefined, ''] or validMimeTypes.indexOf(type) > -1
          true
        else
          # return true if no mime types are provided
          alert "Invalid file type.  File must be one of following types #{validMimeTypes}"
          false

      # for dragover and dragenter (IE) we stop the browser from handling the
      # event and specify copy as the allowable effect
      element.bind 'dragover', processDragOverOrEnter
      element.bind 'dragenter', processDragOverOrEnter

      # on drop events we stop browser and read the dropped file via the FileReader
      # the resulting droped file is bound to the image property of the scope of this directive
      element.bind 'drop', (event) ->
        event?.preventDefault()
        reader = new FileReader()
        reader.onload = (evt) ->

          if checkSize(size) and isTypeValid(type)
            scope.$apply ->
              scope.mainArea.file = evt.target.result
              scope.mainArea.fileName = name if angular.isString scope.mainArea.fileName

        file = if event.dataTransfer then event.dataTransfer.files[0] else event.originalEvent.dataTransfer.files[0]
        name = file.name
        type = file.type
        size = file.size
        reader.readAsText(file, 'UTF-8')
        return false
