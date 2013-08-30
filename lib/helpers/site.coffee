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
app    = require "../../../../yoi.yml"

class Site extends Rest

  constructor: (@request, @response, @next) -> 
    super
    @cookies = {}
    @request.headers.cookie and @request.headers.cookie.split(";").forEach (cookie) =>
      parts = cookie.split("=")
      @cookies[parts[0].trim()] = (parts[1] or "" ).trim()

  cookie: (key) -> @cookies[key]

  run: (html, cookie) ->
    headers = 
      "Content-Type"    : "text/html"
      "Content-Length"  : html.length
    @response.writeHead 200, _setCookieInHeader(headers, cookie)
    @response.write html
    do @response.end

  template: (file, properties = {}, cookie) ->
    try
      page = fs.readFileSync "#{app.templates}/#{file}.jade", "utf8"
    catch exception
      try
        page = fs.readFileSync "#{app.templates}/404.jade", "utf8"
      catch e
        page = "h1 404 - Not found"

    properties.basedir = app.templates
    properties.layout = false
    properties.pretty = false

    html = jade.render page, properties
    @run html, cookie

  redirect: (url, cookie) ->
    headers = "location": url
    @response.writeHead 302, _setCookieInHeader(headers, cookie)
    do @response.end

exports = module.exports = Site

_setCookieInHeader = (headers, cookie) ->
  if cookie?
    headers["Set-Cookie"] = Cookie.serialize app.session.cookie, cookie, maxAge: app.session.expire, httpOnly: true, path:"/"
  else if cookie is null
    headers["Set-Cookie"] = Cookie.serialize app.session.cookie, cookie, maxAge: 0.001, httpOnly: true, path:"/"
  headers
