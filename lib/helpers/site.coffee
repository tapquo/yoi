###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/site
###
"use strict"

Rest   = require "./rest"
fs     = require "fs"
jade   = require "jade"
Cookie = require "cookie"
shell     = require "./shell"
# Configuration
config = global.config

class Site extends Rest

  constructor: (@request, @response, @next) ->
    super
    @cookies = {}
    @request.headers.cookie and @request.headers.cookie.split(";").forEach (cookie) =>
      parts = cookie.split("=")
      @cookies[parts[0].trim()] = (parts[1] or "" ).trim()

  cookie: (key) -> @cookies[key]

  run: (html, cookie, code = 200) ->
    if config.environment.log?.response
      arrow = if cookie then "⇒" else "⇢"
      shell arrow, "green", code, "#{html.length} bytes"

    headers = "Content-Type": "text/html"
    @response.writeHead code, _setCookieInHeader(headers, cookie)
    @response.write html
    do @response.end

  template: (file, properties = {}, cookie) ->
    code = if file is "404" then 404 else 200
    try
      page = fs.readFileSync "#{config.templates}/#{file}.jade", "utf8"
    catch exception
      code = 404
      try
        page = fs.readFileSync "#{config.templates}/404.jade", "utf8"
      catch e
        page = "h1 404 - Not found"

    properties.basedir = config.templates
    properties.layout = false
    properties.pretty = false

    html = jade.render page, properties
    @run html, cookie, code

  redirect: (url, cookie) ->
    shell "↪", "green", "REDIRECT", url

    headers = "location": url
    @response.writeHead 302, _setCookieInHeader(headers, cookie)
    do @response.end

exports = module.exports = Site


_setCookieInHeader = (headers, cookie) ->
  if cookie? or cookie is null
    attributes =
      maxAge  : if cookie? then config.session.expire else 0.001
      httpOnly: true
      path    :"/"
    attributes.domain = config.session.domain if config.session.domain?
    headers["Set-Cookie"] = Cookie.serialize config.session.cookie, cookie, attributes
  headers
