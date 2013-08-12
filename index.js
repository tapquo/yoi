/*jslint node: true, indent: 4, maxlen: 80 */
/*
    YOI
    @description  Easy (but powerful) NodeJS Server
    @version      0.8.13
    @author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi
*/
"use strict";

require("coffee-script");
require("js-yaml");
require("colors");

var Yoi = {
    // Helpers
    Rest      : require("./lib/helpers/rest"),
    Site      : require("./lib/helpers/site"),
    template  : require("./lib/helpers/template"),
    Cron      : require("./lib/helpers/cron"),
    // Services
    Mongo     : require("./lib/services/mongo"),
    Redis     : require("./lib/services/redis"),
    Appnima   : require("./lib/services/appnima"),
    // Facade
    Mongoose  : require("mongoose"),
    // Instance
    run       : function(callback) {
        process.stdout.write('\u001B[2J\u001B[0;0f');
        console.log('================================================'.rainbow);
        console.log(' YOI'.rainbow, 'v0.8.13'.grey);
        console.log(' Easy (but powerful) NodeJS server');
        console.log('', 'http://yoi.tapquo.com'.underline.blue);
        console.log('================================================'.rainbow);
        require("./lib/server").run(callback);
    }
};

module.exports = Yoi;
