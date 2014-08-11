{$, $$, ScrollView} = require 'atom'

path = require 'path'

require './to-base64-view-extensions'
ToBase64 = require './to-base64-core'

module.exports =
class ToBase64View extends ScrollView
  @content: ->
    @div class: 'to-base64 padded pane-item native-key-bindings', tabindex: -1, =>
      @ul class: 'background-message centered', =>
        @li 'Stay Awhile and Listen...'

  initialize: ({@pathToOpen}) ->
    super

    @toBase64 = new ToBase64 @pathToOpen, (error) =>
      @ready()

  afterAttach: ->
    # keep settings
    $('.to-base64').css
      'font-family': atom.config.get('editor.fontFamily')
      'font-size': atom.config.get('editor.fontSize')

  getTitle: ->
    return 'base64 - ' + path.basename(@pathToOpen)

  getStatus: ->
    return 'foo'

  ready: ->
    b64 = @toBase64
    $('.to-base64').empty().append $$ ->
      @toBase64View b64, yes

  # Returns an object that can be retrieved when package is activated
  #serialize: ->

  # Tear down any state and detach
  #destroy: ->
  #  @detach()
