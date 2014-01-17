/*jslint node: true, indent: 4, maxlen: 80 */
/*
    YOI
    @description  Easy (but powerful) NodeJS Server
    @version      0.10.03
    @author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi
*/
"use strict";

require("coffee-script");
require("js-yaml");
require("colors");

var fs = require("fs");
var yaml = require('js-yaml');
var path = require('path');

var yoi = path.join(__dirname, '../../yoi.yml');
global.config = yaml.safeLoad(fs.readFileSync(yoi, 'utf8'));

var environment = path.join(__dirname, '../../environments/' + global.config.environment + ".yml");
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
    console.log(' YOI'.rainbow, 'v0.11.13'.grey);
    console.log(' Easy (but powerful) NodeJS server');
    console.log('', 'http://yoi.tapquo.com'.underline.blue);
    console.log('================================================================================'.rainbow);
};
