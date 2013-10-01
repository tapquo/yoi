###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/model
###
"use strict"

module.exports =

  exception: (error, message) ->
    error   : error
    message : message

  # 400 Client Error
  badRequest: (message = "Bad Request: malformed request") ->
    @exception 400, message

  unauthorized: (message = "Unauthorized: requires authentication") ->
    @exception 401, message

  forbidden: (message = "Forbidden: denied access to the resource") ->
    @exception 403, message

  notFound: (message = "Resource not found") ->
    @exception 404, message

  notAllowed: (message = "Not Allowed: invalid HTTP format") ->
    @exception 405, message

  conflict: (message = "Conflict: resource newer than the client’s timestamp") ->
    @exception 409, message

  # 500 Server Error
  serverError: (message = "Internal Server Error") ->
    @exception 500. message

  notImplemented: (message = "Not Implemented: server does not yet support the requested functionality.") ->
    @exception 501. message

  badGateway: (message = "Bad Gateway") ->
    @exception 502, message

  serviceUnavailable: (message = "Service Unavailable") ->
    @exception 503, message
