var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'VideoUpload', 'coolMethod', [arg0]);
};

function parseOptions(args) {
    var a = [];
    a.push(args.poolID || null);
    a.push(args.region || null);
    a.push(args.bucket || null);
    a.push(args.folder || null);
    a.push(args.cameraWidth || 0);
    a.push(args.cameraHeight || 0);
    return a;
} 

function parseLiveOptions(args) {
    var a = [];
    a.push(args.cameraWidth || 0);
    a.push(args.cameraHeight || 0);
    return a;
}
    
var VideoUpload = {
    init:function(options) {
        exec(function() {}, function() {}, 'VideoUpload', 'init', parseOptions(options));
    },
    startUpload:function(pluginType, successCB, errorCB) {
        exec(successCB, errorCB, 'VideoUpload', 'startUpload', [pluginType]);
    },
    initLive:function(options) {
        exec(function() {}, function() {}, 'VideoUpload', 'initLive', parseLiveOptions(options));
    },
    startBroadcast:function(rtmpURL) {
        exec(function() {}, function() {}, 'VideoUpload', 'startBroadcast', [rtmpURL]);
    }
};

module.exports = VideoUpload;