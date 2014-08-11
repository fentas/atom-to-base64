{$} = require 'atom'

ToBase64View = null
ToBase64InsertView = null

fs   = require 'fs'
path = require 'path'

module.exports =
  activate: (state) ->
    atom.project.registerOpener (uriToOpen) ->
      return unless path.extname(uriToOpen) is '.tobase64'

      ToBase64View ?= require './to-base64-view'
      new ToBase64View pathToOpen: uriToOpen.replace(/\.tobase64$/, '')


    atom.workspaceView.command 'to-base64:view', =>
      if uri = @selectedFile()
        atom.workspaceView.open("#{uri}.tobase64")

    atom.workspaceView.command 'to-base64:insert', =>
      return unless editor = @getEditor()
      atom.workspaceView.focus()
      # grap only first selection for this
      selection = editor.getSelection()
      text = selection.getText()

      line = editor.getCursor().getCurrentBufferLine()
      if ( ! text or text == '' ) and /url\(['"]?(.+?)["']?\)/i.test(line)
        text = RegExp.$1.trim()

        selectedBufferRange = selection.getBufferRange()
        c = selectedBufferRange.start.column
        s = line.indexOf(text)
        e = text.length
        selection.setBufferRange(selectedBufferRange.translate([0, s - c], [0, (s + e) - c]))

        if /^data:/.test text
          text = ''
        else if text != '' and ! (new RegExp('(:|^\\.|^\\'+path.sep+')', '')).test text
          text = './' + text

      ToBase64InsertView ?= require './to-base64-insert-view'
      new ToBase64InsertView text.trim()

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
