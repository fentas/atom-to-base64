{SelectListView, $$, $} = require 'atom'

PathScanner = require './path-scanner'

path = require 'path'
fs = require 'fs-plus'

# http://james.padolsey.com/javascript/regex-selector-for-jquery/
$.expr[':'].regex = (elem, index, match)->
  matchParams = match[3].split(',')
  validLabels = /^(data|css):/
  attr = {
    method: if matchParams[0].match(validLabels) then matchParams[0].split(':')[0] else 'attr',
    property: matchParams.shift().replace(validLabels,'')
  }
  regex = new RegExp(matchParams.join('').replace(/^\s+|\s+$/g,''), 'ig')
  return regex.test($(elem)[attr.method](attr.property))


module.exports =
class ToBase64DataView extends SelectListView
  initialize: (selection, fileRoot, projRoot) ->
    super
    @selection = if /url\(['"]?(.+?)["']?\)/i.test(selection) then RegExp.$1.trim() else ''
    if /^data:(.+?);/.test @selection
      @selection = RegExp.$1
    else if @selection != '' and ! /(:|^\.|^\/)/.test @selection
      @selection = './' + @selection

    console.info @selection

    @listOfItems = ['$1']

    @addClass 'overlay from-top select-list'
    @setItems @listOfItems

    atom.workspaceView.append(this)
    @focusFilterEditor()

  # Here you specify the view for an item
  viewForItem: (item) ->
    query = if @query.trim() == '' then @selection else @query
    list = @list

    $$ ->
      if query

        if /^(https?|ftps?|\/\/)/.test query
          @li class: 'two-lines selected', =>
            @div class: 'status status-renamed icon icon-diff-renamed', ''
            @div class: 'primary-line icon icon-file-symlink-file', 'Download file...'
            @div class: 'secondary-line', query

        else if /^(\.?\.?\/)/.test query
          file = atom.project.resolve query
          if file and fs.existsSync file and fs.lstatSync(file).isFile()
            @li class: 'two-lines selected', =>
              @div class: 'status status-added icon icon-diff-added', ''
              @div class: 'primary-line icon icon-file-text', 'Insert file...'
              @div class: 'secondary-line', query
          else
            @span class: 'inline-block status-ignored icon icon-diff-ignored', ''
            @div 'File not found...'

        else
          scanner = new PathScanner(atom.project.getPath(), inclusions: [query])

          scanner.on 'path-found', (filePath) ->
            ext = path.extname(filePath)
            if fs.isReadmePath(filePath)
              typeClass = 'icon-book'
            else if fs.isCompressedExtension(ext)
              typeClass = 'icon-file-zip'
            else if fs.isImageExtension(ext)
              typeClass = 'icon-file-media'
            else if fs.isPdfExtension(ext)
              typeClass = 'icon-file-pdf'
            else if fs.isBinaryExtension(ext)
              typeClass = 'icon-file-binary'
            else
              typeClass = 'icon-file-text'

            fileBasename = path.basename(filePath)

            _file = $$ ->
              @li =>
                @div class: "inline-block file icon #{typeClass}", ''
                @span 'data-name': fileBasename, 'data-path': atom.project.relativize(filePath), fileBasename
            _file.data('select-list-item', type: 'file', path: filePath)
            list.append _file

          scanner.on 'finished-scanning', ->
            console.log('All done!')

          list.empty()
          scanner.scan()
          #for file in files
          #  break unless ++i <= 10
          #  file = $(file)
          #  @li =>
          #    @div class: 'inline-block '+file.attr('class'), ''
          #    @span 'data-path': file.attr('data-path'), file.attr('data-name')

          #if i > 10
          #  @li =>
          #    @div class: 'status-ignored icon icon-diff-ignored', ''
          #    @span "and #{files.length - i} more..."
        #  catch e
        #    console.warn e

      else
          @div 'test'


  populateList: ->
    super

  getFilterQuery: ->
    @query = super ? ''
    ''

  confirmed: (item) ->
    console.log(item)
