{SelectListView, $$} = require 'atom'

require './to-base64-view-extensions'

path = require 'path'
fs = require 'fs'

module.exports =
class ToBase64DataView extends SelectListView
  initialize: (@query, fileRoot, projRoot) ->
    super

    @query = if /url\(['"]?(.+?)["']?\)/i.test @query then RegExp.$1 else ''
    if /^data:(.+?);/.test @query
      @query = RegExp.$1

    @listOfItems = ['$1']

    @addClass('overlay from-top select-list')
    @setItems(@listOfItems)

    atom.workspaceView.append(this)
    @focusFilterEditor()

  # Here you specify the view for an item
  viewForItem: (item) ->
    console.warn @query, item
    if @query
      if /^(https?|ftps?|\/\/)/.test @query
        console.info RegExp.$1

        $$ ->
          @li class: 'selected', =>
            @div class: 'status status-renamed icon icon-diff-renamed', ''
            @div class: 'primary-line icon icon-file-symlink-file', 'Download file...'

      else if /^(\.?\.?\/)/.test @query
        console.info RegExp.$1
        #file = path.resolve(if RegExp.$1 == '/' then projRoot else fileRoot, $1)
        if fs.existsSync file

          $$ ->
            @li class: 'selected', =>
              @div class: 'status status-added icon icon-diff-added', ''
              @div class: 'primary-line icon icon-file-text', 'Insert file...'

        else
          $$ ->
            @div class: 'text-warning', 'File not found...'
      else
        query = @query
        $$ ->
          @li =>
            @div class: 'pull-right key-bindings', =>
              @colorizedCodeBlock 'key-binding to-base64-search-pattern', 'source.js.regexp', '/' + query + '/i'
            @span class: 'icon icon-file-text', 'Look for file name...'

            if /^[a-z_-]+\/?[a-z_-]*$/i.test(query)
              @li =>
                @div class: 'pull-right key-bindings', =>
                  @colorizedCodeBlock 'to-base64-search-pattern key-binding', 'source.js.regexp', if /^[a-z_-]+\/[a-z_-]*$/i.test(query) then query else 'image/' + query
                @span class: 'icon icon-file-text', 'Look for mime type ~ '

    else
      $$ ->
        @div 'test'


  populateList: ->
    super

  getFilterQuery: ->
    @query = super ? ''
    ''

  confirmed: (item) ->
    console.log(item)
