{$} = require 'atom'

url = require 'url'
http = require 'http'

path = require 'path'
fs = require 'fs'
mime = require 'mime'
sizeOf = require 'image-size';

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

  path  : ''
  name  : ''
  mime  : ''

  constructor: (string, callback) ->
    @path = string

    Object.observe @, (changes) =>
      @_.parse()

    if /(https?|ftp):/.test url.parse(string).protocol
      http.get url.parse(string), (response) =>
        return callback.call @, response unless response.statusCode is 200

        @mime = response.headers['content-type']
        body = ''
        response.on 'data', (chunk) ->
          body += chunk

        response.on 'end', =>
          @base64 = @encode body
          try $.extend @_ sizeOf(body) catch __
          callback.call @

      .on 'error', (error) =>
        callback.call @, error

    else if fs.existsSync string
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
