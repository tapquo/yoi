/*jslint node: true, indent: 4, maxlen: 80 */
/*
    YOI
    @description  Easy (but powerful) NodeJS Server
    @version      0.10.03
    @author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi
*/
"use strict";

var CoffeeScript= require("coffee-script");
var fs          = require("fs");
var yaml        = require('js-yaml');
var path        = require('path');

// Register CoffeeScript if exits
if(CoffeeScript.register) CoffeeScript.register();

// Load YOI.config
var config = path.join(__dirname, '../../yoi.yml');
global.config = yaml.safeLoad(fs.readFileSync(config, 'utf8'));

// Load YOI.environment
var environment;
var parameter = process.argv[2] === undefined ? global.config.environment : process.argv[2];
environment = path.join(__dirname, '../../environments/' + parameter + ".yml");
global.config.environment = yaml.safeLoad(fs.readFileSync(environment, 'utf8'));


var Yoi = {
    // Helpers
    Cron        : require("./lib/helpers/cron"),
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
    console.log(' YOI'.rainbow, 'v1.12.15'.grey);
    console.log(' Easy (but powerful) NodeJS server');
    console.log('', 'http://yoi.tapquo.com'.underline.blue);
    console.log('================================================================================'.rainbow);
};
