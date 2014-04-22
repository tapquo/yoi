###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/cron
###
"use strict"
shell   = require("./shell")
CronJob = require("cron").CronJob

class Cron

  constructor: (@cron) ->
    console.log "✓".grey, "#{cron.name}".underline.grey, "at #{cron.schedule}"
    @instance = new CronJob
      cronTime  : cron.schedule,
      onTick    : @start,
      start     : true,
      timeZone  : (cron.timeZone) or "Europe/Madrid"

  start: =>
    @time = new Date()
    shell "⇡", "grey", "CRON/#{@constructor.name}", "started"
    do @execute

  stop: ->
    console.log "▣".grey, "CRON/#{@constructor.name}".underline.grey, "stopped"
    @instance.stop()

  execute: ->


exports = module.exports = Cron
