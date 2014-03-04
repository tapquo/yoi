###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org>   || @soyjavi
@author       Catalina Oyaneder <catalina@tapquo.org> || @cataflu

@namespace    lib/helpers/shell
###
"use strict"

moment    = require "moment"

module.exports = (label, color, code, messages...) ->
  messages = messages[0] if messages.length is 1
  console.log "[#{label}]"[color], "#{__now()}".white, "#{code}".underline[color], messages

__now = ->
  moment().format("DD MMM HH:mm:ss:SSS")
