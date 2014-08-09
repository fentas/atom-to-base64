{SelectListView, $$} = require 'atom'

path = require 'path'
fs = require 'fs'

module.exports =
class ToBase64DataView extends SelectListView
  initialize: (text, fileRoot, projRoot) ->
    super

    if /url\(['"]?(.+?)["']?\)/i.test text
      $1 = RegExp.$1
      if /^data:(.+?);/.test $1

      else if /^(https?|ftps?|\/\/)/.test $1

      else if /^(\.?\.?\/)/.test $1
        file = path.resolve(if RegExp.$1 == '/' then projRoot else fileRoot, $1)
        if fs.existsSync file

        else



    #if fs.existsSync text

    @listOfItems = ['Search files names', 'Download']

    @addClass('overlay from-top select-list')
    @setItems(@listOfItems)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  # Here you specify the view for an item
  viewForItem: (item) ->
    $$ ->
      @li =>
        @raw item

  populateList: ->
    super

  getFilterQuery: ->
    ''

  confirmed: (item) ->
    console.log(item)
