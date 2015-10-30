define(['module'], function(module) {
    'use strict';

    var ga_id = window.GOOGLE_ANALYTICS.ga_id,
        domain = window.GOOGLE_ANALYTICS.domain || 'auto',
        ga_mod_wrapper;

    if (ga_id) {
        // Setup temporary Google Analytics objects.
        window.GoogleAnalyticsObject = "__ga__";
        window.__ga__ = function() {
            (window.__ga__.q = window.__ga__.q || []).push(arguments);
        };
        window.__ga__.l = 1 * new Date();

        // Immediately add a pageview event to the queue.
        window.__ga__("create", ga_id, domain);
        window.__ga__("send", "pageview");

        // Create a function that wraps `window.__ga__`.
        // This allows dependant modules to use `window.__ga__` without knowingly
        // programming against a global object.
        ga_mod_wrapper = function() {
            window.__ga__.apply(this, arguments);
        };

        // Asynchronously load Google Analytics, letting it take over our `window.__ga__`
        // object after it loads. This allows us to add events to `window.__ga__` even
        // before the library has fully loaded.
        var head = document.getElementsByTagName('head')[0],
            script = document.createElement('script');

        script.async = true;
        script.src = '//www.google-analytics.com/analytics.js';

        head.appendChild(script);
    }

    return ga_mod_wrapper;

});
