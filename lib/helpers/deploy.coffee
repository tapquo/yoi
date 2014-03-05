###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org>   || @soyjavi
@author       Catalina Oyaneder <catalina@tapquo.org> || @cataflu

@namespace    lib/helpers/deploy
###
"use strict"

childProcess  = require 'child_process'
Hope          = require "hope"
shell         = require "./shell"
config        = global.config

module.exports =

  tasks: ->
    promise = new Hope.Promise()

    tasks = config.environment.deploy or config.deploy
    processes = (process task for task in tasks)
    Hope.shield(processes).then (error, result) -> promise.done error, result

    promise

  process: (command, args) -> ->
    shell "T", "magenta", "COMMAND", command
    promise = new Hope.Promise()
    childProcess.exec command, args, (error, out, stdout) ->
      promise.done error, out
    promise
