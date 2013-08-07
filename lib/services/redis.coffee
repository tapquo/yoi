###
YOI
@description  Easy (but powerful) NodeJS Server
@version      0.8.07
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/redis
###
"use strict"

redis = require "redis"

Redis =
  open: (host, port, password) ->
    #APPFOG
    if process.env.VCAP_SERVICES
      env = JSON.parse(process.env.VCAP_SERVICES)
      if env["redis-2.2"]?
        credentials = env["redis-2.2"][0]["credentials"]
        host = credentials.host
        port = credentials.port
        password = credentials.password
    @client = redis.createClient port, host
    @client.auth password if password?
    @client.on "error", (err) -> console.log "  -  [REDIS] Error connecting: #{err}"
    @client.on "connect", -> console.log "  - [REDIS] Listening at #{host}:#{port}"

  close: ->
    console.log "  - [REDIS] Closed"
    do @client.quit

  set: (key, value) -> @client.SET String(key), value

  json: (key, value) -> @client.SET String(key), JSON.stringify value

  incr: (key, callback) -> @client.INCR String(key), callback

  decr: (key, callback) -> @client.DECR String(key), callback

  expire: (key, time) -> @client.EXPIRE String(key), time

  remove: (key) -> @client.DEL String(key)

  get: (key, callback) ->
    @client.GET key, (error, result) ->
      result = JSON.parse result if result?
      callback error, result

  cache: (key, value, expire, json=true) ->
    if json then @json key, value else @set key, value
    @client.EXPIRE String(key), expire

module.exports = Redis
