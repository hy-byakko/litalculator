// Generated by CoffeeScript 1.6.3
define(['jquery', 'underscore', 'backbone', 'Dropbox', 'eventmgr'], function($, _, Backbone, Dropbox, eventManager) {
  var $login, $signOut, $sync, $view, DropboxProvider, client, signState;
  client = new Dropbox.Client({
    key: 't35la3qyv5bvtry'
  });
  client.authDriver(new Dropbox.AuthDriver.Popup({
    receiverUrl: "http://localhost:4000/dropbox-oauth-receiver.html",
    rememberUser: true
  }));
  client.authenticate({
    interactive: false
  }, function(error) {
    if (error) {
      return alert('Authentication error: ' + error);
    }
  });
  $view = $('#dropbox-view');
  $login = $view.children('#dropbox-login').on('click', function() {
    return DropboxProvider.client.authenticate(void 0, function() {
      return signState(true);
    });
  });
  $sync = $view.children('#dropbox-sync');
  $signOut = $view.children('#dropbox-signout').on('click', function() {
    return DropboxProvider.client.signOut(void 0, function() {
      return signState(false);
    });
  });
  signState = function(signIn) {
    if (signIn) {
      $login.hide();
      return $signOut.show();
    } else {
      $login.show();
      return $signOut.hide();
    }
  };
  if (client.isAuthenticated()) {
    eventManager.trigger('remotesync');
    signState(true);
  } else {
    signState(false);
  }
  $view.show();
  Backbone.Model.prototype.remoteSync = function() {
    var defer,
      _this = this;
    defer = $.Deferred();
    if (DropboxProvider.available()) {
      DropboxProvider.getStore().done(function(store) {
        var remoteRec, remoteRecs;
        remoteRecs = store.getTable(_this.remote.table);
        remoteRec = remoteRecs.query(_.object([_this.remote.key], [_this.get(_this.remote.key)]))[0];
        if (!remoteRec) {
          remoteRecs.insert(_this.toRemoteFormat());
          return defer.resolve(_this, new Event('remotecreate'));
        } else if (!moment(remoteRec.get('createTime')).isSame(_this.get('createTime')) || moment(remoteRec.get('modifyTime')).isAfter(_this.get('modifyTime'))) {
          console.log('localupdate');
          _this.save(_this.toLocalFormat(remoteRec.getFields()));
          return defer.resolve(_this, new Event('localupdate'));
        } else if (moment(remoteRec.get('modifyTime')).isBefore(_this.get('modifyTime'))) {
          console.log('remoteupdate');
          defer.resolve(_this, new Event('remoteupdate'));
          return remoteRec.update(_this.toRemoteFormat());
        } else {
          return defer.resolve(_this, new Event('uptodate'));
        }
      });
    } else {
      defer.reject(this, new Event('Store is not available.'));
    }
    return defer.promise();
  };
  Backbone.Model.prototype.toRemoteFormat = function(item) {
    item = this.toJSON();
    delete item.id;
    return item;
  };
  Backbone.Model.prototype.toLocalFormat = function(item) {
    return item;
  };
  DropboxProvider = (function() {
    function DropboxProvider() {}

    DropboxProvider.client = client;

    DropboxProvider.available = function() {
      return this.client.isAuthenticated();
    };

    DropboxProvider.getStore = function() {
      var _this = this;
      return $.Deferred(function(deferred) {
        if (_this.store) {
          return deferred.resolve(_this.store);
        }
        return client.getDatastoreManager().openDefaultDatastore(function(error, datastore) {
          if (error) {
            console.log('Error opening default datastore: ' + error);
            return deferred.reject(error);
          } else {
            _this.store = datastore;
            return deferred.resolve(_this.store);
          }
        });
      });
    };

    DropboxProvider.closeStore = function() {
      if (this.store) {
        return store.close();
      }
    };

    DropboxProvider.cleanTable = function(name) {
      return this.getStore().done(function(store) {
        var records;
        records = store.getTable(name).query();
        return _.each(records, function(record) {
          return record.deleteRecord();
        });
      });
    };

    return DropboxProvider;

  })();
  window.DropboxProvider = DropboxProvider;
  return DropboxProvider;
});
