"use strict";
(() => {
  "use strict";
  var _script = {};
  _script.__dart = {};
  _script.__dart.callConstructor = function(cls, args) {
    var p = {};
    for (var k = 0; k < cls._natives.length; k++) {
      p['n' + k] = cls._natives[k];
    }
    var handler = {
      get: function(target, prop) {
        if (prop == 'ref') {
          return p;
        }
        return target[prop];
      },
      set: function(target, prop, value) {
        target[prop] = value;
        return true;
      }
    };
    var o = new cls();
    for (var i = 0; i < args.length; i++) {
      o['p' + i] = args[i];
    }
    return new Proxy(o, handler);
  };
  _script.__dart.string = {
    S: {}
  };
  _script.__dart.string.S[1] = function () {
    return String;
  };
  _script.__dart.string.S[2] = function (bytes) {
    return new TextDecoder().decode(new Uint8Array(bytes));
  };
  _script.__dart.string.S[3] = function (charArray) {
    return String.fromCharCode.apply(null, charArray);
  };
  
  // Dart entrypoint
  window.onload = function(e) {
    // Initialize Firebase
    try {
      window.firebase.initializeApp({
        apiKey: "YOUR-WEB-API-KEY",
        authDomain: "OCR-MRZ.firebaseapp.com",
        projectId: "OCR-MRZ",
        storageBucket: "OCR-MRZ.appspot.com",
        messagingSenderId: "YOUR-SENDER-ID",
        appId: "YOUR-WEB-APP-ID"
      });
    } catch(e) {}
    
    // Tesseract.js OCR function
    window.Tesseract = {
      recognize: async function(imagePathOrBase64) {
        try {
          if (typeof Tesseract !== 'undefined') {
            const result = await Tesseract.recognize(
              imagePathOrBase64,
              'eng+ara',
              { logger: m => {} }
            );
            return result.data.text;
          }
          return '';
        } catch (e) {
          return '';
        }
      }
    };
    
    // Signal Flutter that we're ready
    window._flutter_web_jsReady = true;
    window.dispatchEvent(new Event('flutter-web-ready'));
  };
  
  window._dart_cleanup = function() {};
  window._dart_getFunction = function() {
    return null;
  };
})();
