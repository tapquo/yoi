###
YOI
@description  Easy (but powerful) NodeJS Server
@version      0.8.07
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helper/cronjob
###
"use strict"

CronJob = require("cron").CronJob

class Cron

  constructor: (@cron) ->
    console.log "     - '#{cron.name}' at #{cron.schedule}"

    @instance = new CronJob
      cronTime  : cron.schedule, 
      onTick    : @execute,
      start     : true,
      timeZone  : (cron.timeZone) or "Europe/Madrid"

  stop: -> 
    console.log "     - '#{@cron.name}' stopped"
    @instance.stop()

  execute: -> @

exports = module.exports = Cron
