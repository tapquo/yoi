###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/appnima
###
"use strict"

request = require "request"
qs      = require "querystring"

Appnima =

  host    : "http://api.appnima.com/"
  key     : ""

  init: (data) ->
    if data.key? then @key = data.key
    if data.host? then @host = data.host
    console.log "\n[\u2713]".yellow, "APPNIMA".underline.yellow, "conected to", "#{@host}".underline.yellow


  subscribe: (mail, callback) ->
    @_proxy "POST", "user/subscription", {mail: mail}, {Authorization: "basic #{@key}"}, callback


  signup: (mail, password, username, callback) ->
    parameters =
      mail      : mail
      password  : password
      username  : username
    @_proxy "POST", "user/signup", parameters, Authorization: "basic #{@key}", (error, result) =>
      if result?
        parameters.grant_type = "password"
        @_proxy "POST", "oauth2/token", parameters, Authorization: "basic #{@key}", (error, token) ->
          if token?
            result[attribute] = token[attribute] for attribute of token
          else
            result = null
          callback.call callback, error, result
      else
        callback.call callback, error, null


  login: (mail, password, username, callback) ->
    parameters =
      mail      : mail
      password  : password
      username  : username
    @_proxy "POST", "user/login", parameters, Authorization: "basic #{@key}", callback


  refreshToken: (refresh_token, callback) ->
    parameters =
      refresh_token : refresh_token
      grant_type    : "refresh_token"
    @_proxy "POST", "oauth2/token", parameters, Authorization: "basic #{@key}", callback


  api: (method, url, token, parameters, callback) ->
    headers = if token? then authorization: "bearer #{token}" else null
    @_proxy method, url, parameters, headers, callback


  _proxy: (method, url, parameters = {}, headers = {}, callback) ->
    method = method.toUpperCase()
    options =
      method  : method
      uri     : "#{@host}#{url}"
      headers : headers
    if parameters? and (method is "GET" or method is "DELETE")
      options.uri += "?#{qs.stringify(parameters)}"
    else
      options.form = parameters

    request options, (error, response, body) ->
      result = JSON.parse body if body?
      if response.statusCode >= 400
        error = code: response.statusCode, message: result.message
        result = null
      callback.call callback, error, result if callback?

module.exports = Appnima
