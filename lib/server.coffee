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
Hope        = require "hope"
mongo       = require "./services/mongo"
redis       = require "./services/redis"
appnima     = require "./services/appnima"
Site        = require "./helpers/site"

# Configuration
app         = require "../../../yoi.yml"
env         = require "../../../environments/#{app.environment}.yml"
folder      = "../../../"
crons       = []

Server =

  run: (callback) ->
    @instance = restify.createServer()

    Hope.shield([=>
      do @assets
    , =>
      do @middleware
    , =>
      do @services
    , =>
      do @endpoints
    , =>
      do @start
    , =>
      do @crons
    ]).then (error, value) =>
      unless error
        do @events
        do @close
        console.log "\n[\u2713]".rainbow, "YOI".rainbow, "listening at", "#{@instance.url}".rainbow

  assets: ->
    promise = new Hope.Promise()
    if app.assets?
      console.log "\n[ ]".yellow, "ASSETS".underline.yellow
      for asset in app.assets
        name = asset.folder or asset.file
        console.log "[\u2713]".yellow, "Loaded", name.underline.yellow, "cached for #{asset.maxage} seconds"

        pattern = if asset.folder? then "/\/#{asset.folder}\/.*/" else "/#{asset.file}"
        @instance.get pattern, restify.serveStatic
            directory  : "assets/"
            maxAge     : asset.maxage or 0
    promise.done null, true
    promise

   middleware: ->
    promise = new Hope.Promise()
    @instance.use restify.queryParser()
    @instance.use restify.bodyParser()
    @instance.use (req, res, next) ->
      _setCORS res
      do next
    @instance.use _setSession
    promise.done null, true
    promise

  services: ->
    promise = new Hope.Promise()
    tasks = []
    if env.mongo? 
      tasks.push(=> mongo.open connection) for connection in env.mongo
    if env.redis?
      tasks.push => redis.open env.redis.host, env.redis.port, env.redis.password
    if env.appnima?
      tasks.push => appnima.init env.appnima

    if tasks.length > 0
      Hope.shield(tasks).then (error, value) => promise.done error, value
    else
      promise.done null, true
    promise

  endpoints: ->
    promise = new Hope.Promise()
    console.log "\n[ ]".blue, "ENDPOINTS".underline.blue
    url = "http://#{env.server.host}"
    url += ":#{env.server.port}" if env.server.port
    for type of app.endpoints
      for endpoint in app.endpoints[type]
        console.log "[\u2713]".blue, "Published endpoints via file", "#{type}/#{endpoint}".underline.blue
        require("#{folder}/endpoints/#{type}/#{endpoint}") @instance 
    promise.done null, true
    promise

  start: ->
    promise = new Hope.Promise()
    @instance.listen process.env.VCAP_APP_PORT or env.server.port, =>
      callback.call callback, @instance if callback?
      promise.done null, true
    promise

  crons: ->
    promise = new Hope.Promise()
    if app.crons?
      console.log "\n[ ]".grey, "CRONS".underline.grey
      for cron in app.crons
        crons.push new (require("#{folder}/crons/#{cron.file}")) cron
    promise.done null, true
    promise

  events: ->
    @instance.on "error", (error) -> console.log error
    @instance.on "MethodNotAllowed", _unknownMethodHandler
    @instance.on "NotFound", _notFoundHandler

    process.on "SIGTERM", => @instance.close()
    process.on "SIGINT", => @instance.close()
    process.on "exit", -> 
      console.log "\n[·]".rainbow, "YOI".rainbow, "stopped correctly"
    process.on "uncaughtException", (error) -> 
      console.error "[X]".red, "EXCEPTION".underline.red, error

  close: ->
    @instance.on "close", ->
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
  site = new Site request, response
  site.template "404"

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
