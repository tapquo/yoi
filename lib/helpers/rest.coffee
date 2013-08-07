###
YOI
@description  Easy (but powerful) NodeJS Server
@version      0.8.07
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helper/rest
###
"use strict"

restify   = require "restify"

class Rest

  constructor: (@request, @response) -> 
    @session = @request.session
    @cookies = {}
    @request.headers.cookie and @request.headers.cookie.split(";").forEach (cookie) =>
      parts = cookie.split("=")
      @cookies[parts[0].trim()] = (parts[1] or "" ).trim()

  required: (parameters = []) ->
    for param in parameters
      if !@request.params[param]?
        throw code: 400, message: "#{param} is required."

  cookie: (key) -> @cookies[key]

  parameter: (name) -> @request.params[name] or null

  connectionIP: ->
    if @request.headers.hasOwnProperty "x-forwarded-for"
      @request.headers['x-forwarded-for'].split(",")[0]
    else
      @request.connection.remoteAddress

  run: (parameters, headers={}) ->
    @response.setHeader name, headers[name] for name of headers
    @response.json parameters

  write: (data) ->
    @response.write data

  exception: (code, message) ->
    console.error code, message
    error = new Error message
    error.statusCode = code
    @response.send error

  httpResponse: (code, status) ->
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
  badRequest: (status = "Bad Request: malformed request") -> @exception 400, status

  unauthorized: (status = "Unauthorized: requires authentication") -> @exception 401, status

  forbidden: (status = "Forbidden: denied access to the resource") -> @exception 403, status

  notFound: (status = "Resource not found") -> @exception 404, status

  notAllowed: (status = "Not Allowed: invalid HTTP format") -> @exception 405, status

  conflict: (status = "Conflict: resource newer than the client’s timestamp") -> @exception 409, status

  # 500 Server Error
  serverError: (status = "Internal Server Error") -> @exception 500. status

  notImplemented: (status = "Not Implemented: server does not yet support the requested functionality.") -> @exception 501. status

  badGateway: (status = "Bad Gateway") -> @exception 502, status

  serviceUnavailable: (status = "Service Unavailable") -> @exception 503, status

exports = module.exports = Rest
