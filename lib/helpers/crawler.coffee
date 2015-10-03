###
YOI
@description  Easy (but powerful) NodeJS Server
@author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi

@namespace    lib/helpers/crawler
###
"use strict"
cheerio = require("cheerio")
request = require("request")
shell   = require("./shell")
CronJob = require("cron").CronJob

class Crawler

  options:
    headers    :
      "user-agent": "request"
    max_threads: 40


  working: false
  time   : 0

  constructor: (crawler) ->
    console.log "✓".grey, "#{crawler.name}".underline.grey, "at #{crawler.schedule}"
    @events = {}
    @instance = new CronJob
      cronTime  : crawler.schedule,
      onTick    : @start,
      start     : true,
      timeZone  : crawler.timeZone or "Europe/Madrid"


  # Instance public methods
  start: (urls = [], callback) ->
    unless @working
      @time = new Date()
      @current_threads = 0
      @parsed_urls = []
      @pending_urls = []
      @queue_data = {}

      shell "⇡", "grey", "CRAWLER/#{@constructor.name}", "started"
      @queue url, callback for url in urls
      @working = true
      @_checkQueue()
    else
      shell "⇡", "red", "CRAWLER/#{@constructor.name}", " still working."

  stop: ->
    console.log "▣".grey, "CRAWLER/#{@constructor.name}".underline.grey, "stopped"
    @instance.stop()
    @working = false

  finish: ->
    seconds = parseInt((new Date() - @time) / 1000)
    shell "⇣", "grey", "CRAWLER/#{@constructor.name}", "finished in #{seconds}s"
    @working = false

  queue: (url, callback, log = true) ->
    if log
      shell "⇢", "grey", "CRAWLER/#{@constructor.name}", url.replace("http://www.", "")
    if @parsed_urls.indexOf(url) is -1 and @pending_urls.indexOf(url) is -1
      @queue_data[url] = data: url, callback: callback
      @pending_urls.push(url)

  on: (event_name, callback) ->
    @events[event_name] = @events[event_name] or []
    @events[event_name].push(callback) if @events[event_name].indexOf(callback) is -1


  # Instance private methods
  _lazyRequestCallback: (url) ->
    (error, response, body) =>
      @_receiveResponse.call(@, error, response, cheerio(body), url)

  _checkQueue: ->
    url = @pending_urls.shift()
    while url
      @_makeRequest(@queue_data[url].data, @_lazyRequestCallback(url))
      @parsed_urls.push(url)
      @current_threads++
      if @current_threads >= @options.max_threads then break
      url = @pending_urls.shift()

    if @current_threads is 0
      do @finish

  _makeRequest: (data, callback) ->
    data =
      url     : data
      headers : @options.headers
      encoding: "utf-8"
      # data.encoding = "binary" or @options.encoding

    request data, callback
    return

  _receiveResponse: (error, response, body, url) ->
    @current_threads--
    if not error and response.statusCode is 200
      @queue_data[url].callback.call(this, error, response, body)
      @_checkQueue()
    return

exports = module.exports = Crawler
