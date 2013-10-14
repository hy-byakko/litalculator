// Generated by CoffeeScript 1.6.3
define(['jquery', 'underscore', 'backbone', 'moment', 'dropboxprovider'], function($, _, Backbone, moment, DropboxProvider) {
  'use strict';
  return Backbone.Model.extend({
    defaults: function() {
      return {
        createTime: new Date,
        lastModifyTime: new Date,
        contentTime: void 0,
        content: []
      };
    },
    remote: {
      table: 'recordContainers',
      key: 'contentTime'
    },
    remoteSync: function() {
      var defer,
        _this = this;
      defer = $.Deferred();
      DropboxProvider.getStore().done(function(store) {
        var remoteRec, remoteRecs;
        remoteRecs = store.getTable(_this.remote.table);
        remoteRec = remoteRecs.query(_.object([_this.remote.key], [_this.get(_this.remote.key)]))[0];
        if (!remoteRec) {
          remoteRecs.insert(_this.toRemoteFormat());
          return defer.resolve(_this, new Event('remotecreate'));
        } else if (!moment(remoteRec.get('createTime')).isSame(_this.get('createTime')) || moment(remoteRec.get('lastModifyTime')).isAfter(_this.get('lastModifyTime'))) {
          console.log('localupdate');
          _this.fetchRemote(remoteRec.getFields());
          return defer.resolve(_this, new Event('localupdate'));
        } else if (moment(remoteRec.get('lastModifyTime')).isBefore(_this.get('lastModifyTime'))) {
          console.log('remoteupdate');
          defer.resolve(_this, new Event('remoteupdate'));
          return remoteRec.update(_this.toRemoteFormat());
        } else {
          return defer.resolve(_this, new Event('uptodate'));
        }
      });
      return defer.promise();
    },
    toRemoteFormat: function() {
      var recCntr;
      recCntr = this.toJSON();
      recCntr.content = JSON.stringify(recCntr.content);
      delete recCntr.id;
      return recCntr;
    },
    fetchRemote: function(recCntr) {
      recCntr.content = JSON.parse(recCntr.content);
      return this.save(recCntr);
    }
  });
});
