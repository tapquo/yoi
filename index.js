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

global.config = require("../../yoi.yml");
global.config.environment = require("../../environments/" + global.config.environment + ".yml");

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
        require("./lib/server").run(callback);
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
    console.log(' YOI'.rainbow, 'v0.10.03'.grey);
    console.log(' Easy (but powerful) NodeJS server');
    console.log('', 'http://yoi.tapquo.com'.underline.blue);
    console.log('================================================================================'.rainbow);
};
