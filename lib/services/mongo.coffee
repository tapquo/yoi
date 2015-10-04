###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/mongo
###
"use strict"

mongoose = require "mongoose"
Hope     = require "hope"
shell    = require "../helpers/shell"

module.exports =
  connections: {}

  open: (connection = {}) ->
    promise = new Hope.Promise()
    url = connection.uri || connection.host + ":" + connection.port + "/" + connection.db
    if connection.user and connection.password
      url = connection.user + ":" + connection.password + "@" + url

    @connections[connection.name] = mongoose.createConnection "mongodb://#{url}"
    @connections[connection.name].on "error", (error) ->
      shell "⚑", "red", "MONGO", error
      promise.done true, null
      process.exit()
    @connections[connection.name].on "connected", (error) ->
      console.log "✓".green, "MONGO/#{connection.name}".underline.green, "listening at",
        "#{url.replace(/(?:mongodb:\/\/(?:[^@]*@)?)(.+)/, "$1")}".underline.green
      promise.done null, true
    promise

  close: ->
    for name of @connections
      @connections[name].close ->
        console.log "▣".green, "MONGO/#{name}".underline.green, "closed connection"
