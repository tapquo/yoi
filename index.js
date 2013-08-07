/*jslint node: true, indent: 4, maxlen: 80 */
/*
    YOI
    @description  Easy (but powerful) NodeJS Server
    @version      0.8.07
    @author       Javi Jimenez Villar <javi@tapquo.org> || @soyjavi
*/
"use strict";

require("coffee-script");

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
    run       : function(callback){
        require("./lib/server").run(callback);
    }
};

module.exports = Yoi;
