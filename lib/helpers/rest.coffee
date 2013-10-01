###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/rest
###
"use strict"

restify   = require "restify"
moment    = require "moment"
Model     = require "./model"
# Configuration
config = global.config

class Rest

  constructor: (@request, @response, @next) ->
    @session = @request.session
    _inputLog @request if config.environment.log?.request

  required: (parameters = []) ->
    for param in parameters
      if !@request.params[param]?
        throw code: 400, message: "#{param} is required."

  parameter: (name) -> @request.params[name] or null

  connectionIP: ->
    if @request.headers.hasOwnProperty "x-forwarded-for"
      @request.headers['x-forwarded-for'].split(",")[0]
    else
      @request.connection.remoteAddress

  run: (parameters, headers={}) ->
    _outputLog @response.statusCode, "{#{Object.keys(parameters).length}}", "green"
    @response.setHeader name, headers[name] for name of headers
    @response.json parameters

  write: (data) ->
    @response.write data

  exception: (code, message) ->
    _outputLog code, message, "red"
    error = new Error message
    error.statusCode = code
    @response.send error

  httpResponse: (code, status) ->
    _outputLog code, status, "green"
    @response.statusCode = code
    if status
      @response.json "message": status
    else
      @response.json {}

  successful: (status = "Successful") -> @httpResponse 200, status

  created: (status = "Resource created") -> @httpResponse 201, status

  accepted: (status = "Request accepted") -> @httpResponse 202, status

  noContent: (status = "Resource deleted") -> @httpResponse 204, status

  resetContent: (status = "Reset Content") -> @httpResponse 205, status

  partialContent: (status = "Partial Content") -> @httpResponse 206, status

  # 300 Redirection
  redirect: (url) -> @httpResponse 301, url

  movedPermanently: (status = "Moved Permanently: resource in new location") -> @httpResponse 301, status

  seeOther: (status = "See Other: resource in temporarily new location") -> @httpResponse 303, status

  notModified: (status = "Not Modified: resource has not changed") -> @httpResponse 304, status

  # 400 Client Error
  badRequest: (status) -> @_parseException Model.badRequest status

  unauthorized: (status) -> @_parseException Model.unauthorized status

  forbidden: (status) ->  @_parseException Model.forbidden status

  notFound: (status) ->   @_parseException Model.notFound status

  notAllowed: (status) -> @_parseException Model.notAllowed status

  conflict: (status) ->   @_parseException Model.conflict status

  # 500 Server Error
  serverError: (status) -> @_parseException Model.serverError status

  notImplemented: (status) -> @_parseException Model.notImplemented status

  badGateway: (status) -> @_parseException Model.badGateway status

  serviceUnavailable: (status) -> @_parseException Model.serviceUnavailable status

  _parseException: (model) -> @exception model.error, model.message

exports = module.exports = Rest

_outputLog = (code, status, color="green") =>
  if config.environment.log?.response
    console.log "[>]"[color], "#{_now()}".grey, "#{code}".underline[color], status

_inputLog = (request) ->
  secured = "[Authenticated]" if request.session
  console.log "\n[<]".blue, "#{_now()}".grey, "#{request.method}".underline.blue, request.path(), "#{secured}".grey

_now = ->
  moment().format("HH:mm:ss:SSS - MMM DD YYYY")
