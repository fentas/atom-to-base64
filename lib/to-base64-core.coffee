

url = require 'url'
http = require 'http'

path = require 'path'
fs = require 'fs'
#mime = require 'mime'

module.exports =
class ToBase64
  _: null

  mime  : null
  width : null
  height: null

  constructor: (string, callback) ->
    if /(https?|ftp):/.test url.parse(string).protocol
      http.get url.parse(string), (response) =>
        return callback.call @, response unless response.statusCode is 200

        @mime = response.headers['content-type']
        body = ''
        response.on 'data', (chunk) ->
          body += chunk

        response.on 'end', =>
          @_ = @encode body
          callback.call @

      .on 'error', (error) =>
        callback.call @, error

    else if fs.existsSync(string)
      #@mime = mime.lookup(string)
      fs.readFile string, (err, data) =>
        return callback.call @, err if err
        @_ = @encode data
        callback.call @

    else
      @_ = @encode string
      callback.call @

  encode: (string, encoding) ->
    return (new Buffer string, encoding).toString('base64')

  decode: (string, encoding) ->
    return (new Buffer string, 'base64').toString(encoding)

  toString: (encoding) ->
    return @_
    ###
    return switch encoding
      when 'data' then
        "data:#{type};base64,#{text}"
      when 'css' then
        """
          div.image {
            width: #{width}px;
            height: #{height}px;
            background-image: URL('#{@base64data base64}')
          }
        """
      when 'xhtml' then
        """
          div.image {
            width: #{width}px;
            height: #{height}px;
            background-image: URL('#{@base64data base64}')
          }
        """
      when 'xml' then
        """

        """
###
