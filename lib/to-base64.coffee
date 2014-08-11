{$} = require 'atom'

ToBase64View = null
ToBase64DataView = null

fs   = require 'fs'
path = require 'path'

module.exports =
  activate: (state) ->
    atom.project.registerOpener (uriToOpen) ->
      return unless path.extname(uriToOpen) is '.tobase64'

      ToBase64View ?= require './to-base64-view'
      new ToBase64View pathToOpen: uriToOpen.replace(/\.tobase64$/, '')


    atom.workspaceView.command 'to-base64:view', ->
      if uri = @selectedFile()
        atom.workspaceView.open("#{uri}.tobase64")

    atom.workspaceView.command 'to-base64:data', =>
      return unless editor = @getEditor()
      atom.workspaceView.focus()
      # grap only first selection for this
      selection = editor.getSelection()
      text = selection.getText()
      text = editor.getCursor().getCurrentBufferLine() if text.trim() == ''

      ToBase64DataView ?= require './to-base64-data-view'
      new ToBase64DataView text

    atom.workspaceView.command "to-base64:encode", =>
      return unless editor = @getEditor()
      for selection in editor.getSelections()
        selection.insertText (new Buffer selection.getText()).toString('base64'), 'select': true

    atom.workspaceView.command "to-base64:decode", =>
      return unless editor = @getEditor()
      for selection in editor.getSelections()
        selection.insertText (new Buffer selection.getText(), 'base64').toString('utf8'), 'select': true

  ## Utility methods

  getEditor: ->
    atom.workspace.getActiveEditor()

  selectedFile: ->
    selected = $('.tree-view .file.selected')?.view()
    if selected
      uri = selected.getPath()
      return uri if uri and fs.existsSync(uri)
      console.warn "File (#{uri}) does not exists"
    else
      console.warn "No file selected"
    return false

  parseURI: (string) ->
    return false
