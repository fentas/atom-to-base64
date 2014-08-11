{SelectListView, $$, $} = require 'atom'

ToBase64 = require './to-base64-core'

module.exports =
class ToBase64InsertAsView extends SelectListView
  initialize: (item) ->
    super

    @addClass 'overlay from-top select-list'
    @setLoading 'Stay Awhile and Listen...'
    atom.workspaceView.append(this)
    @focusFilterEditor()

    i = 0
    @base64 = new ToBase64 item, ((error)=>
      return @setError(error) if error
      @listOfItems = [label: 'base64', data: content: @base64.base64]
      for lang, data of @base64.get()
        @listOfItems[if lang == 'data' then 'unshift' else 'push'](label: lang, data: data)
      @setLoading ''
      @setItems @listOfItems), (length)=> @loadingBadge.text 'Chunk '+(++i)+' ~ Size '+(Math.floor(length / 1024 * 100)/100)+'KB'

  # Here you specify the view for an item
  viewForItem: (item) ->
    if item.label == 'css'
      typeClass = 'icon-book'
    else if item.label == 'data'
      typeClass = 'icon-file-media'
    else if item.label == 'xhtml'
      typeClass = 'icon-file-symlink-file'
    else
      typeClass = 'icon-file-text'

    $$ ->
      @li =>
        @div class: "inline-block file icon #{typeClass}", ''
        @span item.label

  confirmed: (item) ->
    return unless editor = @getEditor()
    for selection in editor.getSelections()
      selection.insertText @base64.c3po(item.data.content), 'select': true
    # close ListView
    @cancel()

  getEditor: ->
    atom.workspace.getActiveEditor()
