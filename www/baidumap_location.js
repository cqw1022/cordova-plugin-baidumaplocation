var exec = require('cordova/exec');

var baidumap_location = {
    setRadarId: function (userId){
        //               exec(successCallback, errorCallback, 'BaiduMapLocation', 'setRadarId', [{userId:userId}]);
        return new Promise((resolve,reject)=>{
                           exec(function(){
                                resolve({
                                        isSuccess: true
                                        })
                                },
                                function(errorCode){
                                resolve({
                                        isSuccess: false,
                                        errorCode: errorCode
                                        })
                                }, "BaiduMapLocation", "setRadarId", [{userId:userId}]);
                           })
    },
    setCommandCallback: function (messageCallback){
        //               exec(successCallback, errorCallback, 'BaiduMapLocation', 'setRadarId', [{userId:userId}]);
        var cb = function(msgStr) {
            if (typeof msgStr === "string" && msgStr.length > 0) {
                messageCallback(JSON.parse(msgStr))
            }
        }
        return new Promise((resolve,reject)=>{
                           exec(cb,
                                cb, "BaiduMapLocation", "setCommandCallback", []);
                           })
    },
    getNearBy: function (radius) {
        return new Promise((resolve,reject)=>{
                           exec(function(){
                                resolve({
                                        isSuccess: true
                                        })
                                },
                                function(errorCode){
                                resolve({
                                        isSuccess: false,
                                        errorCode: errorCode
                                        })
                                }, "BaiduMapLocation", "getNearBy", [{radius:radius}]);
                           })
    },
    getCurrentPosition: function () {
        return new Promise((resolve,reject)=>{
                           exec(function(){
                                resolve({
                                        isSuccess: true
                                        })
                                },
                                function(errorCode){
                                resolve({
                                        isSuccess: false,
                                        errorCode: errorCode
                                        })
                                }, "BaiduMapLocation", "getCurrentPosition", []);
                           })
        //        // Timer var that will fire an error callback if no position is retrieved from native
        //        // before the "timeout" param provided expires
        //        var timeoutTimer = {timer: null};
        //
        //        var win = function (p) {
        //            clearTimeout(timeoutTimer.timer);
        //            if (!(timeoutTimer.timer)) {
        //                // Timeout already happened, or native fired error callback for
        //                // this geo request.
        //                // Don't continue with success callback.
        //                return;
        //            }
        //            successCallback(p);
        //        };
        //        var fail = function (e) {
        //            clearTimeout(timeoutTimer.timer);
        //            timeoutTimer.timer = null;
        //            if (errorCallback) {
        //                errorCallback(e);
        //            }
        //        };
        //
        //        if (options && options.timeout !== Infinity) {
        //            // If the timeout value was not set to Infinity (default), then
        //            // set up a timeout function that will fire the error callback
        //            // if no successful position was retrieved before timeout expired.
        //            timeoutTimer.timer = createTimeout(fail, options.timeout);
        //        } else {
        //            // This is here so the check in the win function doesn't mess stuff up
        //            // may seem weird but this guarantees timeoutTimer is
        //            // always truthy before we call into native
        //            timeoutTimer.timer = true;
        //        }
        //        exec(win, fail, 'BaiduMapLocation', 'getCurrentPosition', [options]);
        //        return timeoutTimer
    }
};

// Returns a timeout failure, closed over a specified timeout value and error callback.
function createTimeout(errorCallback, timeout) {
    var t = setTimeout(function () {
        clearTimeout(t);
        t = null;
        errorCallback({
            code: -1,
            message: "Position retrieval timed out."
        });
    }, timeout);
    return t;
}

module.exports = baidumap_location
