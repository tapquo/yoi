###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/server
###
"use strict"

# Libraries
restify     = require "restify"
fs          = require "fs"
Hope        = require "hope"
moment      = require "moment"
# Configuration
folder      = "../../../"
global.test = require "../../../yoitest.yml"

Test =

  run: () ->
    tests = []
    for file in test.files
      tests = tests.concat do require("#{folder}/test/#{file}")

    test.counters = total: tests.length, success: 0, current: 0
    Hope.chain(tests).then (error, result) ->
      coverage = ((test.counters.success * 100) / test.counters.total).toFixed(2)
      failed = test.counters.total - test.counters.success
      console.log('================================================================================'.rainbow);
      console.log (if coverage >= 95 then "[\u2713]".green else "[x]".red) ,"TEST COVERAGE:", "#{coverage}%"[if coverage < 95 then "red" else "green"], " (".grey, "#{failed}".red, "/ #{test.counters.total} )".grey
      console.log('================================================================================'.rainbow);

module.exports = Test
