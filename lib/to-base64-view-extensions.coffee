{$, $$, $$$, EditorView, View} = require 'atom'

$.extend View,
  toBase64View: (base64, useStatusBar) ->
    _buttons = $$ ->
      @div class: 'btn-group btn-group-xs btn-toggle', =>
        @button class: 'btn selected', 'data-display-class': 'show-to-base64-base64', 'base64'
    _content = $$ ->
      @div class: 'to-base64-content', =>
        @colorizedCodeBlock 'to-base64-base64 selected', 'text.plain', base64.base64

    for lang, data of base64.get()
      _buttons.append $$ -> @button class: 'btn', 'data-display-class': 'show-to-base64-'+lang, lang
      # @div => ... workaround https://github.com/atom/space-pen/issues/48
      _content.append $$ -> @div => @colorizedCodeBlock 'to-base64-'+lang, data.grammar, base64.c3po(data.content)

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
