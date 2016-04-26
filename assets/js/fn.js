define([
    'module',
    'jquery',
    'modernizr',
    'es6!foundation',
    'es6!foundation.dropdown',
    'es6!foundation.equalizer',
    'es6!foundation.util.box',
    'es6!foundation.util.keyboard',
    'es6!foundation.util.mediaQuery',
    'es6!foundation.util.motion',
    'es6!foundation.util.timerAndImageLoader',
    'es6!foundation.util.touch'
], function(module, $) {
    'use strict';

    $(document).ready(function() {
        // loads foundation
        $(document).foundation();
    });

    return module;
});
