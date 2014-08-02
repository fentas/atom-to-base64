{$} = require 'atom'

ToBase64View = null

fs   = require 'fs'
path = require 'path'

module.exports =
  activate: (state) ->
    atom.project.registerOpener (uriToOpen) ->
      return unless path.extname(uriToOpen) is '.tobase64'

      ToBase64View ?= require './to-base64-view'
      new ToBase64View pathToOpen: uriToOpen.replace(/\.tobase64$/, '')

    atom.workspaceView.command 'to-base64:view', ->
      selected = $('.tree-view .file.selected')?.view()
      if selected
        uri = selected.getPath()
        if uri and fs.existsSync(uri)
          atom.workspaceView.open("#{uri}.tobase64")
        else
          console.warn "File (#{uri}) does not exists"
      else
        console.warn "No file selected"

  #deactivate: ->
  #  @toBase64View.destroy()

  #serialize: ->
  #  toBase64ViewState: @toBase64View.serialize()
