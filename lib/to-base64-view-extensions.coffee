{$, $$, EditorView, View} = require 'atom'

View.colorizedCodeBlock = (cssClass, grammarScopeName, code) ->
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

  console.warn editorBlock
  @subview '__', editorBlock
