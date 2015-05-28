{$, $$, $$$, EditorView, View} = require 'atom-space-pen-views'
#Highlights = require 'highlights'

highlighter = null

$.extend View,
  toBase64View: (base64, useStatusBar) ->
    _buttons = $$ ->
      @div class: 'btn-group btn-group-xs btn-toggle', =>
        @button class: 'btn selected', 'data-display-class': 'show-to-base64-base64', 'base64'
    _content = $$ ->
      @div class: 'to-base64-content', =>
        #@colorizedCodeBlock 'to-base64-base64 selected', 'text.plain', base64.base64
        @pre class: 'to-base64-base64 selected base64-text-editor', base64.base64

    for lang, data of base64.get()
      _buttons.append $$ -> @button class: 'btn', 'data-display-class': 'show-to-base64-'+lang, lang
      # @div => ... workaround https://github.com/atom/space-pen/issues/48
      #_content.append $$ -> @div => @colorizedCodeBlock 'to-base64-'+lang, data.grammar, base64.c3po(data.content)
      _content.append $$ -> @pre class: 'to-base64-'+lang+' base64-text-editor', base64.c3po(data.content)

    _buttons.find('.btn').bind 'click', ->
      btn = $(this)
      base = btn.parents('.to-base64')
      clas = btn.attr('data-display-class')

      base.find('.btn, .base64-text-editor').removeClass('selected')
      base.attr 'class', base[0].className.replace(/\s*show-.+?(\s|$)/g, '')
      base.addClass(clas)
      base.find('.'+clas.replace(/^show\-/, '')).addClass('selected')

      btn.addClass('selected')


    @div =>
      @subview '__', _buttons
      @subview '__', _content

  colorizedCodeBlock: (cssClass, grammarScopeName, code) ->
    highlighter ?= new Highlights(registry: atom.grammars)
    highlightedHtml = highlighter.highlightSync
      fileContents: code
      scopeName: grammarScopeName

    highlightedBlock = $(highlightedHtml)
    # The `editor` class messes things up as `.editor` has absolutely positioned lines
    highlightedBlock.removeClass('editor')
    highlightedBlock.addClass(cssClass + ' base64-text-editor')
    if fontFamily = atom.config.get('editor.fontFamily')
      highlightedBlock.css('font-family', fontFamily)

    @subview '__', highlightedBlock
