###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/mongo
###
"use strict"

mongoose = require "mongoose"
Hope     = require "hope"
shell    = require "./shell"

module.exports =
  connections: {}

  open: (connection = {}) ->
    promise = new Hope.Promise()
    url = connection.host + ":" + connection.port + "/" + connection.db
    if connection.user and connection.password
      url = connection.user + ":" + connection.password + "@" + url

    @connections[connection.name] = mongoose.connect "mongodb://#{url}", (error, result) ->
      if error
        console.log "[x]".green, "MONGO.#{connection.name}".underline.green, error.message
        promise.done error, null
      else
        console.log "[\u2713]".green, "MONGO.#{connection.name}".underline.green, "listening at", "#{connection.host}:#{connection.port}/#{connection.db}".underline.green
        promise.done null, true
    @connections[connection.name].connection.on "error", (error) ->
      shell "[x]", "red", "MONGO", error
      process.exit()
    promise

  close: ->
    for name of @connections
      @connections[name].connection.close ->
        console.log "[·]".green, "MONGO".underline.green, "Closed", "#{name}".underline.green ,"connection"
