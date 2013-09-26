"use strict"

require "color"
Hope      = require "hope"
server    = global.config.environment.server

Socket = require "socket.io-client"


module.exports =
  connect: (container, description="", _server) ->
    server = _server if _server?
    promise = new Hope.Promise()
    test.counters.current++
    container.socket = Socket.connect "http://#{server.host}:#{server.port}", "force new connection": true
    container.socket.on "connect", () ->
      test.counters.success++
      console.log "[\u2713]".green, "#{__formatNumber(test.counters.current)}".white, "#{description}".grey
      promise.done null, true
    container.socket.on "connect_failed", ->
      console.log "[x]".red, "#{__formatNumber(test.counters.current)}".white, "#{description}".red
      console.log "        connect_failed:".grey, "http://#{server.host}:#{server.port}"
      promise.done "connect_failed", null
    promise

  exec: (sender, send_event="", receiver, receive_event="", data=[], description="", callback) ->
    promise = new Hope.Promise()
    test.counters.current++
    timer = null
    receiver.socket.on receive_event, ->
      clearTimeout timer
      test.counters.success++
      console.log "[\u2713]".green, "#{__formatNumber(test.counters.current)}".white, "#{description}".grey
      callback.apply callback, arguments if callback?
      promise.done null, true

    aArgs = [send_event].concat data
    sender.socket.emit.apply sender.socket, aArgs

    timer = setTimeout ->
      console.log "[x]".red, "#{__formatNumber(test.counters.current)}".white, "#{description}".red
      console.log "        #{send_event}-->#{receive_event}:".grey, "http://#{server.host}:#{server.port}"
      promise.done "#{send_event}-->#{receive_event}", null
    , 250

    promise

__formatNumber = (number) ->
  number = number.toString()
  number = "0" + number while number.length < 3
  number