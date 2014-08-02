{$, $$, $$$, EditorView, View} = require 'atom'

#require './subview'

CSON = require 'season'
coffee = require 'coffee-script'

$.extend View,
  parseToBase64: (base64, useStatusBar) ->
    _buttons = $$ ->
      @div class: 'btn-group btn-group-xs btn-toggle', =>
        @button class: 'btn selected', 'data-display-class': 'show-to-base64-base64', 'base64'
    _content = $$ ->
      @div class: 'to-base64-content', =>
        @colorizedCodeBlock 'to-base64-base64 selected', 'text.plain', base64.base64

    if base64.mime?
      mtypes = CSON.readFileSync __dirname + '/mime-types.cson'
      get = null

      c3po = (data) ->
        {@name, @width, @height, @base64, @mime, @_} = base64
        @get = get
        foo = coffee.eval '"""'+data.replace(/\t/g, '#{\'  \'}')+'"""'
        return foo

      get = (type, method) ->
        return unless /^(.+?)(?:\/(.+))?$/.test type
        obj = mtypes[RegExp.$1][RegExp.$2] ? mtypes[RegExp.$1]['_'] if mtypes[RegExp.$1]?
        return obj unless method?
        return c3po obj[method].content

      for lang, data of get base64.mime
        _buttons.append $$ -> @button class: 'btn', 'data-display-class': 'show-to-base64-'+lang, lang
        # @div => ... workaround https://github.com/atom/space-pen/issues/48
        _content.append $$ -> @div => @colorizedCodeBlock 'to-base64-'+lang, data.grammar, c3po(data.content)

    _buttons.find('.btn').bind 'click', ->
      btn = $(this)
      base = btn.parents('.to-base64')
      clas = btn.attr('data-display-class')

      base.find('.btn, .editor').removeClass('selected')
      base.attr 'class', base[0].className.replace(/\s*show-.+?(\s|$)/g, '')
      base.addClass(clas)
      base.find('.'+clas.replace(/^show\-/, '')).addClass('selected')

      btn.addClass('selected')


    @div =>
      @subview '__', _buttons
      @subview '__', _content

  colorizedCodeBlock: (cssClass, grammarScopeName, code) ->
    editorBlock = $$ ->
      @pre class: cssClass+' editor-colors editor', ''

    refreshHtml = (grammar) ->
      editorBlock.empty()
      for tokens in grammar.tokenizeLines(code)
        editorBlock.append(EditorView.buildLineHtml({tokens, text: code}))

    if grammar = atom.syntax.grammarForScopeName(grammarScopeName)
      refreshHtml(grammar)
    else
      atom.syntax.on 'grammar-added grammar-updated', (grammar) ->
        return unless grammar.scopeName == grammarScopeName
        refreshHtml(grammar)

    @subview '__', editorBlock
