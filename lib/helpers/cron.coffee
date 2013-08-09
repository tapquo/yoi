###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/cron
###
"use strict"

CronJob = require("cron").CronJob

class Cron

  constructor: (@cron) ->
    console.log "[\u2713]".magenta, "#{cron.name}".underline.magenta, "at #{cron.schedule}"

    @instance = new CronJob
      cronTime  : cron.schedule, 
      onTick    : @execute,
      start     : true,
      timeZone  : (cron.timeZone) or "Europe/Madrid"

  stop: -> 
    console.log "[·]".magenta, "CRON".underline.magenta, "named", "#{@cron.name}".underline.magenta, "stopped"
    @instance.stop()

  execute: -> @

exports = module.exports = Cron
