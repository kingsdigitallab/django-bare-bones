// The build will inline common dependencies into this file.
// For any third party dependencies, like jQuery, place them in the lib folder.
// Configure loading modules from the lib directory,
// except for 'app' ones, which are in a sibling
// directory.
requirejs.config({
    baseUrl: '/static/js',
    urlArgs: 'bust=' + (new Date()).getTime(),
    paths: {
        'jquery': '../vendor/jquery/dist/jquery',

        'es6': '../vendor/requirejs-babel/es6',
        'babel': '../vendor/requirejs-babel/babel-5.8.34.min',

        // Foundation
        'foundation': '../vendor/foundation-sites/js/foundation.core',
        'foundation.accordionMenu': '../vendor/foundation-sites/js/foundation.accordionMenu',
        'foundation.drilldown': '../vendor/foundation-sites/js/foundation.drilldown',
        'foundation.dropdown': '../vendor/foundation-sites/js/foundation.dropdown',
        'foundation.dropdownMenu': '../vendor/foundation-sites/js/foundation.dropdownMenu',
        'foundation.equalizer': '../vendor/foundation-sites/js/foundation.equalizer',
        'foundation.responsiveMenu': '../vendor/foundation-sites/js/foundation.responsiveMenu',
        'foundation.responsiveToggle': '../vendor/foundation-sites/js/foundation.responsiveToggle',
        'foundation.util.box': '../vendor/foundation-sites/js/foundation.util.box',
        'foundation.util.keyboard': '../vendor/foundation-sites/js/foundation.util.keyboard',
        'foundation.util.mediaQuery': '../vendor/foundation-sites/js/foundation.util.mediaQuery',
        'foundation.util.motion': '../vendor/foundation-sites/js/foundation.util.motion',
        'foundation.util.nest': '../vendor/foundation-sites/js/foundation.util.nest',
        'foundation.util.timerAndImageLoader': '../vendor/foundation-sites/js/foundation.util.timerAndImageLoader',
        'foundation.util.touch': '../vendor/foundation-sites/js/foundation.util.touch',
        'foundation.util.triggers': '../vendor/foundation-sites/js/foundation.util.triggers',

        'requirejs': '../vendor/requirejs/require',
    },
    shim: {
        'foundation': {
            deps: [
                'jquery'
            ],
            exports: 'Foundation'
        },
        'foundation.util.box': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.keyboard': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.mediaQuery': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.motion': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.nest': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.timerAndImageLoader': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.touch': {
            deps: [
                'foundation'
            ],
        },
        'foundation.util.triggers': {
            deps: [
                'foundation'
            ],
        },
        'foundation.accordionMenu': {
            deps: [
                'foundation',
                'foundation.util.keyboard',
                'foundation.util.motion',
                'foundation.util.nest'
            ],
        },
        'foundation.drilldown': {
            deps: [
                'foundation',
                'foundation.util.keyboard',
                'foundation.util.motion',
                'foundation.util.nest'
            ],
        },
        'foundation.dropdown': {
            deps: [
                'foundation',
                'foundation.util.box',
                'foundation.util.keyboard',
                'foundation.util.triggers'
            ],
        },
        'foundation.dropdownMenu': {
            deps: [
                'foundation',
                'foundation.util.box',
                'foundation.util.keyboard',
                'foundation.util.nest'
            ],
        },
        'foundation.equalizer': {
            deps: [
                'foundation',
                'foundation.util.mediaQuery'
            ],
        },
        'foundation.responsiveMenu': {
            deps: [
                'foundation',
                'foundation.util.triggers',
                'foundation.util.mediaQuery',
                'foundation.util.accordionMenu',
                'foundation.util.drilldown',
                'foundation.util.dropdownMenu'
            ],
        },
        'foundation.responsiveToggle': {
            deps: [
                'foundation',
                'foundation.util.mediaQuery'
            ],
        },
        'ga': {
            exports: '__ga__'
        },
    }
});
