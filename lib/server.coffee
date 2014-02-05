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
config      = global.config
environment = global.config.environment
folder      = "../../../"
crons       = []

Server =

  run: (callback) ->
    if environment.server.https?
      https_options =
        key: fs.readFileSync("#{environment.server.https.key}")
        certificate: fs.readFileSync("#{environment.server.https.certificate}")
      @instance = restify.createServer https_options
    else
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
      if error
        console.error "[X]".red, "ERROR".underline.red, error
      else
        do @events
        do @close
        console.log "\n[\u2713]".rainbow, "YOI".rainbow, "listening at", "#{@instance.url}".rainbow
        if environment.https?
          console.log "\n[\u2713]".rainbow, "YOI HTTPS".rainbow, "listening at", "#{@https_server.url}".rainbow

    @instance

  assets: ->
    promise = new Hope.Promise()
    if config.assets?
      console.log "\n[ ]".yellow, "ASSETS".underline.yellow
      for asset in config.assets
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
    @instance.use restify.gzipResponse()
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
    if environment.mongo?
      tasks.push(=> mongo.open connection) for connection in environment.mongo
    if environment.redis?
      tasks.push => redis.open environment.redis.host, environment.redis.port, environment.redis.password
    if environment.appnima?
      tasks.push => appnima.init environment.appnima

    if tasks.length > 0
      Hope.shield(tasks).then (error, value) => promise.done error, value
    else
      promise.done null, true
    promise

  endpoints: ->
    promise = new Hope.Promise()
    console.log "\n[ ]".blue, "ENDPOINTS".underline.blue
    url = "http://#{environment.server.host}"
    url += ":#{environment.server.port}" if environment.server.port
    for type of config.endpoints
      for endpoint in config.endpoints[type]
        console.log "[\u2713]".blue, "Published endpoints in file", "#{type}/#{endpoint}".underline.blue
        require("#{folder}/endpoints/#{type}/#{endpoint}") @instance
    promise.done null, true
    promise

  start: ->
    promise = new Hope.Promise()
    @instance.listen process.env.PORT or process.env.VCAP_APP_PORT or environment.server.port, =>
      callback.call callback, @instance if callback?
      promise.done null, true
    promise

  crons: ->
    promise = new Hope.Promise()
    if config.crons?
      console.log "\n[ ]".grey, "CRONS".underline.grey
      for cron in config.crons
        crons.push new (require("#{folder}/crons/#{cron.file}")) cron
    promise.done null, true
    promise

  events: ->
    @instance.on "error", (error) ->
      console.error "[X]".red, "ERROR".underline.red, error
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
      console.log('\n================================================\n'.rainbow)
      if environment.mongo? then mongo.close()
      if environment.redis? then redis.close()
      if config.crons? then cron.stop() for cron in crons

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
  response.header "Access-Control-Allow-Headers", config.ALLOWED_HEADERS.join(", ")
  response.header "Access-Control-Allow-Methods", config.ALLOWED_METHODS.join(", ")
  response.header "Access-Control-Expose-Headers", config.EXPOSE_HEADERS.join(", ")
  response.header "Access-Control-Allow-Origin", config.ALLOW_ORIGIN

_setSession = (request, res, next) ->
  rest = config.session.rest
  request.session = null
  request.session = request.headers[rest] if request.headers[rest]?
  if request.headers.cookie?
    request.headers.cookie and request.headers.cookie.split(";").forEach (cookie) ->
      parts = cookie.split("=")
      key = parts[0].trim()
      request.session = (parts[1] or "" ).trim() if key is config.session.cookie
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
