{$} = require 'atom'

http = require 'http'

path = require 'path'
fs = require 'fs'
mime = require 'mime'
sizeOf = require 'image-size'

CSON = require 'season'
coffee = require 'coffee-script'

mtypes = CSON.readFileSync __dirname + '/mime-types.cson'

module.exports =
class ToBase64
  base64: null

  _:
    parse: =>
      @_.name = @name
        .replace(/^([a-z_]+)(\d+)?$/i, (m, name)->
          name.replace(/_/g, ' ')
          .replace(/(?:^|\s)([a-z])/ig, (m, f)->
            ' '+f.toUpperCase() ))
        .trim()
      @_.weight = @name.replace(/^([a-z_]+)(\d+)?$/i, "$2")
      @_.weight = 'normal' if ! /^\d+$/.test @_.weight
      @_.width ?= ''
      @_.height ?= ''

  type  : null
  path  : ''
  name  : ''
  mime  : ''

  constructor: (string, callback, data) ->
    @path = string

    Object.observe @, (changes) =>
      @_.parse()

    if /^(?:(https?)\:)?\/\//.test string
      @type = 'http'
      http = require RegExp.$1
      http.get string, (response) =>
        return callback.call @, response unless response.statusCode is 200

        @mime = response.headers['content-type']
        length = response.headers['content-length']
        chunks = []
        response.on 'data', (chunk) ->
          chunks.push chunk
          data.call(@, length) if typeof data == 'function'

        response.on 'end', =>
          buffer = Buffer.concat chunks
          @base64 = buffer.toString('base64')
          try $.extend @_ sizeOf(buffer) catch e
          callback.call @

      .on 'error', (error) =>
        callback.call @, error

    else if fs.existsSync string
      @type = 'file'
      @mime = mime.lookup string
      @name = path.basename string, path.extname(string)
      console.log 'parsing file', @mime, @name

      fs.readFile string, (err, data) =>
        return callback.call @, err if err

        try $.extend @_, sizeOf(string) catch __
        @base64 = @encode data
        callback.call @

    else
      @base64 = @encode string
      callback.call @

  encode: (string, encoding) ->
    return (new Buffer string, encoding).toString('base64')

  decode: (string, encoding) ->
    return (new Buffer string, 'base64').toString(encoding)

  toString: () ->
    return @base64

  c3po: (data) ->
    return '' unless data and data.trim() != ''
    #TODO: y is extra scope needed?
    return (({@name, @base64, @mime, @_, @get, @c3po})->
      return coffee.eval '"""'+data.replace(/\t/g, '#{\'  \'}')+'"""'
    )(this)

  get: (type, method) ->
    type = type ? @mime
    return unless /^(.+?)(?:\/(.+))?$/.test type
    obj = mtypes[RegExp.$1][RegExp.$2] ? mtypes[RegExp.$1]['_'] if mtypes[RegExp.$1]?
    return obj unless method?
    return @c3po obj[method].content
