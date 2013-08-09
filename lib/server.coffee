###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/server
###
"use strict"

# Libraries
restify     = require "restify"
fs          = require "fs"
mongo       = require "./services/mongo"
redis       = require "./services/redis"
appnima     = require "./services/appnima"
template    = require "./helpers/template"
# Configuration
app         = require "../../../yoi.yml"
env         = require "../../../environments/#{app.environment}.yml"
folder      = "../../../"
crons       = []

Server =

  run: (callback)->
    @srv = restify.createServer()
    do @assets
    do @middleware
    do @services
    do @endpoints
    do @start
    do @events
    do @close

  assets: ->
    if app.assets?
      console.log "\n[ ]".yellow, "ASSETS".underline.yellow
      for asset in app.assets
        name = asset.folder or asset.file
        console.log "[\u2713]".yellow, "Loaded", name.underline.yellow, "cached for #{asset.maxage} seconds"

        pattern = if asset.folder? then "/\/#{asset.folder}\/.*/" else "/#{asset.file}"
        @srv.get pattern, restify.serveStatic
            directory  : "assets/"
            maxAge     : asset.maxage or 0

   middleware: ->
    @srv.use restify.queryParser()
    @srv.use restify.bodyParser()
    @srv.use (req, res, next) ->
      _setCORS res
      do next
    @srv.use _setSession

  services: ->
    if env.mongo? 
      mongo.open connection for connection in env.mongo
    if env.redis? 
      redis.open env.redis.host, env.redis.port, env.redis.password
    if env.appnima?
      appnima.init env.appnima

  endpoints: ->
    console.log "\n[ ]".grey, "ENDPOINTS".underline.grey

    url = "http://#{env.server.host}"
    url += ":#{env.server.port}" if env.server.port

    for type of app.endpoints
      # require("#{folder}/endpoints/#{type}/#{endpoint}").register @srv for endpoint in app.endpoints[type]
      for endpoint in app.endpoints[type]
        console.log "[\u2713]".grey, "Published endpoint at", "#{url}/#{type}/#{endpoint}".underline.grey
        require("#{folder}/endpoints/#{type}/#{endpoint}").register @srv 

  start: ->
    console.log "\n[ ]".blue, "SERVER".underline.blue
    @srv.listen process.env.VCAP_APP_PORT or env.server.port, =>
      console.log "[\u2713]".blue, "Listening at", "#{@srv.url}".underline.blue
      callback.call callback, @srv if callback?

      if app.crons?
        console.log "\n[ ]".magenta, "CRONS".underline.magenta
        for cron in app.crons
          crons.push new (require("#{folder}/crons/#{cron.file}")) cron

  events: ->
    @srv.on "error", (error) -> console.log error
    @srv.on "MethodNotAllowed", _unknownMethodHandler
    @srv.on "NotFound", _notFoundHandler

    process.on "SIGTERM", => @srv.close()
    process.on "SIGINT", => @srv.close()
    process.on "exit", -> console.log "\n[·]".blue, "SERVER".underline.blue, "closed correctly"
    process.on "uncaughtException", (err) -> console.error "Caught exception: #{err}"

  close: ->
    @srv.on "close", ->
      console.log('\n================================================\n'.rainbow);
      if env.mongo? then mongo.close()
      if env.redis? then redis.close()
      if app.crons? then cron.stop() for cron in crons

module.exports = Server


_unknownMethodHandler = (request, response) ->
  _setCORS response
  if request.method.toLowerCase() is "options"
    response.methods.push 'OPTIONS' if response.methods.indexOf('OPTIONS') is -1
    return response.send 204
  else
    response.send new restify.MethodNotAllowedError()

_notFoundHandler = (request, response) ->
  template "404", null, response

_setCORS = (response) ->
  response.header "Access-Control-Allow-Credentials", true
  response.header "Access-Control-Allow-Headers", app.ALLOWED_HEADERS.join(", ")
  response.header "Access-Control-Allow-Methods", app.ALLOWED_METHODS.join(", ")
  response.header "Access-Control-Expose-Headers", app.EXPOSE_HEADERS.join(", ")
  response.header "Access-Control-Allow-Origin", app.ALLOW_ORIGIN

_setSession = (request, res, next) ->
  rest = app.session.rest
  request.session = null
  request.session = request.headers[rest] if request.headers[rest]?
  if request.headers.cookie?
    request.headers.cookie and request.headers.cookie.split(";").forEach (cookie) ->
      parts = cookie.split("=")
      key = parts[0].trim()
      request.session = (parts[1] or "" ).trim() if key is app.session.cookie
  do next

_file = (file, content_type, response, next) ->
  data = fs.readFileSync "public/#{file}", "utf8"
  response.writeHead 200,
    "Content-Type"    : content_type
    "Content-Length"  : data.length
    "Cache-Control"   : "max-age=86400"
  response.write data
  do response.end
  do next
