###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/config
###
"use strict"
fs = require("fs")
yaml = require("js-yaml")

# Inject vars on environment config
injectVariables = (file) ->
  file.replace /#\{(.+)\}/g, (match, code) ->
    code = code.split('.')
    base = new Function("return #{code.shift()}")()
    for variable in code
      base = base[variable]
    base

module.exports = (path) ->
  yaml.safeLoad injectVariables(fs.readFileSync path, 'utf8')
