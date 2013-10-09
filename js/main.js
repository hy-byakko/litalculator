// Generated by CoffeeScript 1.6.3
'use strict';
require.config({
  paths: {
    jquery: 'lib/jquery-2.0.3.min',
    underscore: 'lib/underscore-min',
    backbone: 'lib/backbone-min',
    bootstrap: 'lib/bootstrap.min',
    text: 'lib/text',
    store: 'lib/backbone.localStorage-min',
    moment: 'lib/moment.min',
    'jQuery.scrollUp': 'lib/jquery.scrollUp.min',
    'jQuery.indexedDB': 'lib/jquery.indexeddb.min',
    messenger: 'lib/messenger.min',
    Dropbox: 'lib/dropbox-datastores-1.0.0'
  },
  shim: {
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: ['underscore', 'jquery'],
      exports: 'Backbone'
    },
    bootstrap: ['jquery'],
    store: ['backbone'],
    'jQuery.scrollUp': ['jquery'],
    'jQuery.indexedDB': ['jquery'],
    messenger: {
      deps: ['jquery'],
      exports: 'Messenger'
    },
    Dropbox: {
      exports: 'Dropbox'
    }
  }
});

require(['jquery', 'backbone', 'views/app', 'messenger', 'bootstrap', 'jQuery.scrollUp', 'backbone.indexedDB'], function($, Backbone, appView, Messenger) {
  var updateOnlineStatus;
  Backbone.IndexedDB.DBName = 'litalculator';
  $.scrollUp({
    scrollDistance: 1,
    scrollImg: true
  });
  Messenger.options = {
    extraClasses: 'messenger-fixed messenger-on-top',
    theme: 'air'
  };
  updateOnlineStatus = function() {
    var options;
    options = {
      showCloseButton: true
    };
    if (arguments[0].type === 'online') {
      $.extend(options, {
        message: '上线状态',
        type: 'info'
      });
    } else {
      $.extend(options, {
        message: '目前处于离线状态',
        type: 'error'
      });
    }
    return Messenger().post(options);
  };
  return new appView;
});
