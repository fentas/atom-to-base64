{SelectListView, $$, $} = require 'atom'

PathScanner = require './path-scanner'

ToBase64InsertAsView = null

path = require 'path'
fs = require 'fs-plus'

module.exports =
class ToBase64InsertView extends SelectListView
  initialize: (@selection) ->
    super

    @listOfItems = ['$1']

    @addClass 'overlay from-top select-list'
    @setItems @listOfItems

    atom.workspaceView.append(this)
    @focusFilterEditor()

  # Here you specify the view for an item
  viewForItem: (item) ->
    query = if @query.trim() == '' then @selection else @query
    list = @list
    typeClass = @typeClass

    loadingBadge = @loadingBadge
    setLoading = (message)=> @setLoading message
    setLoading()

    noResults = ->
      setLoading()
      list.empty()
      list.append $$ ->
        @pre =>
          @div class: 'inline-block status-ignored icon icon-diff-ignored', ''
          @span 'Nothing found...'
        @pre =>
          @div class: 'inline-block status-ignored no-icon', ''
          @span 'Use glop expressions (e.g. `*.+(png|jpeg)`)'

    $$ ->
      if query

        if /^(https?:)?\/\//.test query
          @li class: 'two-lines selected', 'select-list-item': query, =>
            @div class: 'status status-renamed icon icon-diff-renamed', ''
            @div class: 'primary-line icon icon-file-symlink-file', 'Download file...'
            @div class: 'secondary-line', query

        else if /^(\.?\.?\/)/.test query
          if query[0] == '/'
            filePath = atom.project.resolve '.'+query
          else
            filePath = path.resolve path.dirname(atom.workspace.getActiveEditor().getPath()), query

          if filePath and fs.existsSync(filePath) and fs.lstatSync(filePath).isFile()
            @li class: 'two-lines selected', 'select-list-item': query, =>
              @div class: 'status status-added icon icon-diff-added', ''
              @div class: "primary-line icon #{typeClass(filePath)}", 'Insert file...'
              @div class: 'secondary-line', query
          else
            incl = query.split(path.sep).pop()
            if incl != '' and ! /^\.{1,2}\/?$/.test incl
              filePath = path.dirname(filePath)

            scanner = new PathScanner(filePath, {inclusions: [incl], deep: false, directories: true})
            setLoading("Listing files...")
            fileCount = 0
            scanner.on 'path-found', (itemPath, isFile) ->
              loadingBadge.text(++fileCount)

              if isFile
                fileBasename = path.basename(itemPath)
                _file = $$ ->
                  @li =>
                    @div class: "inline-block file icon #{typeClass(itemPath)}", ''
                    @span 'data-name': fileBasename, 'data-path': atom.project.relativize(itemPath), fileBasename
                _file.data('select-list-item', itemPath)
                if list.find('.file:last').length
                  _file.insertAfter list.find('.file:last').parent()
                else
                  list.prepend _file
              else
                folder = itemPath.split(path.sep).pop()
                _file = $$ ->
                  @li =>
                    @div class: "inline-block icon icon-file-directory", ''
                    @span 'data-name': folder, 'data-path': atom.project.relativize(itemPath), folder
                _path = query.split(path.sep)
                _path.pop()
                _file.data('select-list-item', {type: 'folder', path: _path.join(path.sep)+path.sep+folder+path.sep})
                list.append _file

            scanner.on 'finished-scanning', ->
              return noResults() if list[0].children.length == 0
              setLoading ''

            list.empty()
            scanner.scan()

        else

          if query.length > 1
            scanner = new PathScanner(atom.project.getPath(), inclusions: [query])
            fileCount = 0
            setLoading("Searching for files...")
            scanner.on 'path-found', (filePath) ->
              loadingBadge.text(++fileCount)

              fileBasename = path.basename(filePath)

              _file = $$ ->
                @li =>
                  @div class: "inline-block file icon #{typeClass(filePath)}", ''
                  @span 'data-name': fileBasename, 'data-path': atom.project.relativize(filePath), fileBasename
              _file.data('select-list-item', filePath)
              list.append _file

            scanner.on 'finished-scanning', ->
              return noResults() if list[0].children.length == 0
              setLoading('Search finished!')

            list.empty()
            scanner.scan()

          else noResults()

      else
        @pre =>
          @div class: "status status-added inline-block file icon icon-file-text", ''
          @span 'Search for files with glob expressions'
        @pre =>
          @div class: "status status-modified inline-block file icon icon-file-submodule", ''
          @span 'Use relative file path (or from project root `/`)'
        @pre =>
          @div class: "status status-renamed inline-block file icon icon-file-symlink-file", ''
          @span 'Insert URI directly'


  populateList: ->
    super

  getFilterQuery: ->
    @query = super ? ''
    ''

  confirmed: (item) ->
    if item.type && item.type == 'folder'
      return @filterEditorView.getEditor().setText(item.path)

    item = @list.find('li.selected').attr('select-list-item') if item == '$1'
    ToBase64InsertAsView ?= require './to-base64-insert-as-view'
    new ToBase64InsertAsView(item)

  typeClass: (filePath) ->
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
    return typeClass
