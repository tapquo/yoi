/*jslint node: true, indent: 4, maxlen: 80 */
/*
    YOI
    @description  Easy (but powerful) NodeJS Server
    @version      1.04.22
    @author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi
    @author       Catalina Oyaneder <catalina@tapquo.org> || @cataflu
*/
"use strict";

var CoffeeScript= require("coffee-script");
var fs          = require("fs");
var yaml        = require('js-yaml');
var path        = require('path');

// Register CoffeeScript if exits
if(CoffeeScript.register) CoffeeScript.register();

// Get endpoints
var endpoint_file = process.argv[2] === undefined ? "yoi" : process.argv[2];
var endpoint_path = path.join(__dirname, '../../' + endpoint_file + ".yml");
global.config = yaml.safeLoad(fs.readFileSync(endpoint_path, 'utf8'));

// Get environment
var environment_name = process.argv[3] === undefined ? global.config.environment : process.argv[3];
var environment_path = path.join(__dirname, '../../yoi/environments/' + environment_name + ".yml");
global.config.environment = yaml.safeLoad(fs.readFileSync(environment_path, 'utf8'));

// Get port
var port = process.argv[4]
if (port !== undefined && !isNaN(port)) global.config.environment.server.port = port;

// Get TimeZone
if (global.config.environment.server.timezone) process.env.TZ = global.config.environment.server.timezone;

var Yoi = {
    // Helpers
    Crawler     : require("./lib/helpers/crawler"),
    Cron        : require("./lib/helpers/cron"),
    Deploy      : require("./lib/helpers/deploy"),
    Model       : require("./lib/helpers/model"),
    Rest        : require("./lib/helpers/rest"),
    Site        : require("./lib/helpers/site"),
    SocketTest  : require("./lib/helpers/test_socket"),
    Test        : require("./lib/helpers/test"),
    // Services
    Mongo       : require("./lib/services/mongo"),
    Redis       : require("./lib/services/redis"),
    Appnima     : require("./lib/services/appnima"),
    // Facade
    Mongoose    : require("mongoose"),
    Hope        : require("hope"),
    Restify     : require("restify"),
    $           : require("cheerio"),
    // Instance
    run         : function(callback) {
        _watermark();
        return require("./lib/server").run(callback);
    },
    // Instance
    test        : function(callback) {
        _watermark();
        require("./lib/test").run();
    }
};

module.exports = Yoi;

var _watermark = function() {
    process.stdout.write('\u001B[2J\u001B[0;0f');
    console.log('================================================================================'.rainbow);
    console.log(' YOI'.rainbow, 'v1.06.19'.white, 'Easy (but powerful) NodeJS server'.grey);
    console.log('', 'http://yoi.tapquo.com'.underline.blue);
    console.log('================================================================================'.rainbow);

    var environment = global.config.environment.server;
    console.log('■'.green, 'ENVIRONMENT'.green.underline);
    console.log('✓'.green, 'Environment', environment.type.green.underline);
    console.log('✓'.green, 'Address', (environment.host + ":" + environment.port).green.underline );
    if (environment.timezone) console.log('✓'.green, 'Timezone', environment.timezone.green.underline);
};
