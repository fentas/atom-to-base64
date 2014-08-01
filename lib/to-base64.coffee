ToBase64View = null

url = require 'url'
fs  = require 'fs'

module.exports =
  activate: (state) ->
    atom.project.registerOpener (uri) ->
      {protocol, host, pathname} = url.parse(uri)
      pathname = decodeURI(pathname) if pathname
      return unless protocol is 'tobase64:'

      ToBase64View ?= require './to-base64-view'
      new ToBase64View(pathToOpen: pathname)
    #@toBase64View = new ToBase64View(state.toBase64ViewState)

    atom.workspaceView.command 'to-base64:view', ->
      if atom.workspace.activePaneItem?
        uri = atom.workspace.activePaneItem.getUri()
        console.info(uri);
        if uri and fs.existsSync(uri)
          atom.workspaceView.open("tobase64://#{uri}")
        else
          console.warn "File (#{uri}) does not exists"

  #deactivate: ->
  #  @toBase64View.destroy()

  #serialize: ->
  #  toBase64ViewState: @toBase64View.serialize()
