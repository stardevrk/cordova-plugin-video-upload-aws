var exec = require('cordova/exec');
var channel = require('cordova/channel');
var cordova = require('cordova');

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
    a.push(JSON.stringify(testData))
    return a;
} 

function parseLiveOptions(args) {
    var a = [];
    a.push(args.cameraWidth || 0);
    a.push(args.cameraHeight || 0);
    a.push(args.stream || '');
    return a;
}
    
var VideoUpload = {
    init:function(options) {
        exec(function() {}, function() {}, 'VideoUpload', 'init', parseOptions(options));
    },
    startUpload:function(pluginType, progressListener, successCB, errorCB) {
        var win = function(result) {
            if (progressListener)
                progressListener(result);
            successCB(result);
        }
        exec(win, errorCB, 'VideoUpload', 'startUpload', [pluginType]);
    },
    saveVideo:function(url, successCB, errorCB) {
        exec(successCB, errorCB, 'VideoUpload', 'saveVideo', [url]);
    },
    initLive:function(options, successCB, errorCB) {
        exec(successCB, errorCB, 'VideoUpload', 'initLive', parseLiveOptions(options));
    },
    startBroadcast:function() {
        exec(function() {}, function() {}, 'VideoUpload', 'startBroadcast', [rtmpURL]);
    },
    addWatcher: function(successCB, errorCB) {
        exec(successCB, errorCB, 'VideoUpload', 'addWatcher');
    },
    getCapturing: function(successCB, errorCB) {
        exec(successCB, errorCB, 'VideoUpload', 'getCurrentCapturing');
    }
};

// channel.createSticky('onCordovaConnectionReady');
// channel.waitForInitialization('onCordovaConnectionReady');
var vuTimerId = null;
var vuTimeout = 500;

channel.onCordovaReady.subscribe(function () {
    VideoUpload.addWatcher(function(captured) {
        if (vuTimerId != null) {
            clearTimeout(vuTimeout)
        } 
        vuTimeout = setTimeout(() => {
            cordova.fireDocumentEvent('captured', captured);
        }, vuTimeout)

        // should only fire this once
        if (channel.onCordovaConnectionReady.state !== 2) {
            channel.onCordovaConnectionReady.fire();
        }
    }, function(e) {
        // should only fire this once
        if (channel.onCordovaConnectionReady.state !== 2) {
            channel.onCordovaConnectionReady.fire();
        }
    });
});

module.exports = VideoUpload;