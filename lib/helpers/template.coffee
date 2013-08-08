###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/template
###
"use strict"

fs      = require "fs"
jade    = require "jade"
Cookie  = require "cookie"
app     = require "../../../../yoi.yml"

Template = (file, properties = {}, response, cookie) ->
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
  headers = 
    "Content-Type"    : "text/html"
    "Content-Length"  : html.length
  if cookie?
    headers["Set-Cookie"] = Cookie.serialize app.session.cookie, cookie, maxAge: app.session.expire, httpOnly: true, path:"/"
  else if cookie is null
    headers["Set-Cookie"] = Cookie.serialize app.session.cookie, cookie, maxAge: 0.001, httpOnly: true, path:"/"
  response.writeHead 200, headers
  response.write html
  do response.end

module.exports = Template
