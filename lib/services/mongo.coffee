###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/services/mongo
###
"use strict"

mongoose = require "mongoose"

Mongo =

  connections: {}

  open: (connection = {}) ->
    #APPFOG
    if process.env.VCAP_SERVICES
      env = JSON.parse(process.env.VCAP_SERVICES)
      if env["mongodb-1.8"]?
        appfog = env["mongodb-1.8"][0]["credentials"]
        connection =
          host      : appfog.hostname or "localhost"
          port      : appfog.port or 27017
          db        : appfog.db or "test"
          username  : appfog.username
          password  : appfog.password

    url = connection.host + ":" + connection.port + "/" + connection.db
    if connection.user and connection.password
      url = connection.user + ":" + connection.password + "@" + url

    @connections[connection.name] = mongoose.connect "mongodb://#{url}", (error, result) ->
      if error
        console.error "\n[MONGO].#{connection.name}".green , "Error: ", error
        process.exit()
      else
        console.log "\n[\u2713]".green, "MONGO".underline.green, "listening at", "#{connection.host}:#{connection.port}/#{connection.db}".underline.green

  close: ->
    for name of @connections
      @connections[name].connection.close -> 
        console.log "[·]".green, "MONGO".underline.green, "Closed", "#{name}".underline.green ,"connection"

module.exports = Mongo
