define([
    'module',
    'jquery',
    'es6!foundation',
    'es6!foundation.accordionMenu',
    'es6!foundation.drilldown',
    'es6!foundation.dropdown',
    'es6!foundation.dropdownMenu',
    'es6!foundation.equalizer',
    'es6!foundation.responsiveMenu',
    'es6!foundation.responsiveToggle',
    'es6!foundation.util.box',
    'es6!foundation.util.keyboard',
    'es6!foundation.util.mediaQuery',
    'es6!foundation.util.motion',
    'es6!foundation.util.nest',
    'es6!foundation.util.timerAndImageLoader',
    'es6!foundation.util.touch',
    'es6!foundation.util.triggers'
], function(module, $) {
    'use strict';

    $(document).ready(function() {
        // loads foundation
        $(document).foundation();
    });

    return module;
});
