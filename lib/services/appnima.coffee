###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/appnima
###
"use strict"

request = require "request"
qs      = require "querystring"
Hope    = require "hope"

Appnima =

  host    : "http://api.appnima.com/"
  key     : ""

  init: (data) ->
    promise = new Hope.Promise()
    if data.key? then @key = data.key
    if data.host? then @host = data.host
    console.log "\n[\u2713]".magenta, "APPNIMA".underline.magenta, "connected to", "#{@host}".underline.magenta
    promise.done null, true
    promise

  subscribe: (mail, callback) ->
    @_proxy "POST", "user/subscription", {mail: mail}, {Authorization: "basic #{@key}"}, callback

  signup: (mail, password, username, callback) ->
    promise = new Hope.Promise()

    parameters = mail: mail, password: password, username: username
    Hope.shield([=>
      @_proxy "POST", "user/signup", parameters, Authorization: "basic #{@key}"
    , (error, signup) =>
      child_promise = new Hope.Promise()
      parameters.grant_type = "refresh_token"
      parameters.refresh_token = signup.refresh_token
      @_proxy("POST", "user/token", parameters, Authorization: "basic #{@key}").then (error, token) ->
        if token?
          signup.access_token = token.access_token
          signup.refresh_token = token.refresh_token
        child_promise.done error, signup
      child_promise
    ]).then (error, value) -> promise.done error, value

    promise


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
    @_proxy "POST", "user/token", parameters, Authorization: "basic #{@key}", callback


  api: (method, url, token, parameters, callback) ->
    headers = if token? then authorization: "bearer #{token}" else null
    @_proxy method, url, parameters, headers, callback


  _proxy: (method, url, parameters = {}, headers = {}, callback) ->
    promise = new Hope.Promise()

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
      promise.done error, result
      callback.call callback, error, result if callback?

    promise

module.exports = Appnima
