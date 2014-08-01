{$, $$, ScrollView} = require 'atom'

require './to-base64-view-extensions'
ToBase64 = require './to-base64-core'

module.exports =
class ToBase64View extends ScrollView
  @content: ->
    @div class: 'to-base64 padded pane-item native-key-bindings', tabindex: -1, outlet: 'content'


  initialize: ({@pathToOpen}) ->
    super

    @toBase64 = new ToBase64 @pathToOpen, (error) =>
      @ready()

  afterAttach: ->

    $('.to-base64').css
      'font-family': atom.config.get('editor.fontFamily')
      'font-size': atom.config.get('editor.fontSize')

  getTitle: ->
    return 'test'

  ready: ->
    b64 = @toBase64

    $('.to-base64').append $$ ->
      @div class: 'btn-group btn-group-xs btn-toggle', =>
        @button class: 'btn selected', 'data-display-class': 'show-to-base4-base64', 'base64'
        @button class: 'btn', 'data-display-class': 'show-to-base64-data', 'data'
        @button class: 'btn', 'data-display-class': 'show-to-base64-css', 'css'
        @button class: 'btn', 'data-display-class': 'show-to-base64-xhtml', 'xhtml'
        @button class: 'btn', 'data-display-class': 'show-to-base64-xml', 'xml'
      @pre class: 'to-base64-base64 editor-colors editor', b64.toString('base64')
      @pre class: 'to-base64-data editor-colors editor', b64.toString('data')
      #@colorizedCodeBlock 'to-base64-base64', 'text.xml', b64.toString('base64')
      #@colorizedCodeBlock 'to-base64-data', 'plain.txt', b64.toString('data')
      #@colorizedCodeBlock 'to-base64-css', 'source.css', b64.toString('css')
      #@colorizedCodeBlock 'to-base64-xhtml', 'text.html', b64.toString('xhtml')
      #@colorizedCodeBlock 'to-base64-xml', 'text.xml', b64.toString('xml')

    @on 'click', '.btn-group .btn', ->
      btn = $(this)
      base = btn.parents('.to-base64')
      clas = btn.attr('data-display-class')

      base.find('.btn').removeClass('selected')
      base.attr 'class', base[0].className.replace(/\s*show-.+?(\s|$)/g, '')
      base.addClass(clas)

      btn.addClass('selected')

  # Returns an object that can be retrieved when package is activated
  #serialize: ->

  # Tear down any state and detach
  #destroy: ->
  #  @detach()
