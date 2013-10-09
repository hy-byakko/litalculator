// Generated by CoffeeScript 1.6.3
define(['jquery', 'underscore', 'backbone', 'jQuery.indexedDB'], function($, _, Backbone) {
  var IndexedDB, Store;
  Backbone.IndexedDB = IndexedDB = (function() {
    function IndexedDB() {}

    IndexedDB.DBName = 'defaultDB';

    return IndexedDB;

  })();
  Backbone.IndexedDB.Store = Store = (function() {
    function Store(name, dataRoot) {
      this.name = name;
      this.dataRoot = dataRoot != null ? dataRoot : 'root';
    }

    Store.prototype.getStore = function() {
      return $.indexedDB(Backbone.IndexedDB.DBName).objectStore(this.name, true);
    };

    Store.prototype.fetch = function(model, options) {
      var _this = this;
      if (model.id !== void 0) {
        return $.Deferred(function(deferred) {
          return _this.getStore().get(model.id).done(function(result, event) {
            return deferred.resolve($.extend(_.object([model.idAttribute || 'id'], [model.id]), result), event);
          }).fail(function(error, event) {
            return deferred.reject(error, event);
          });
        });
      } else {
        return $.Deferred(function(deferred) {
          var resources;
          resources = [];
          return _this.getStore().each(function(instance) {
            resources.push($.extend(_.object([model.idAttribute || 'id'], [instance.key]), instance.value));
            return void 0;
          }).done(function(result, event) {
            var response;
            response = _this.localFilter(resources, options.data);
            return deferred.resolve(response, event);
          }).fail(function(error, event) {
            return deferred.reject(error, event);
          });
        });
      }
    };

    Store.prototype.localFilter = function(resources, rules) {
      var chain, count,
        _this = this;
      if (rules == null) {
        rules = {};
      }
      count = resources.length;
      chain = _.chain(resources);
      _.each(rules, function(value, key, obj) {
        var limit;
        switch (key) {
          case 'page':
            limit = obj.limit || 10;
            return chain = _.chain(chain.value().slice((value - 1) * limit, value * limit));
        }
      });
      resources = chain.value();
      if (rules.page) {
        return _.object([this.dataRoot, 'totalLength'], [resources, count]);
      } else {
        return resources;
      }
    };

    Store.prototype.saveChanges = function(model, options) {
      if (model.id !== void 0) {
        return this.getStore().put(model.toJSON(), model.id);
      } else {
        return this.getStore().add(model.toJSON());
      }
    };

    Store.prototype.destroy = function(model, options) {
      if (model.id) {
        return this.getStore()["delete"](model.id);
      }
    };

    Store.prototype.clear = function() {
      return this.getStore().clear();
    };

    return Store;

  })();
  Backbone.IndexedDB.Store.sync = Backbone.localSync = function(method, model, options) {
    var error, errorMessage, respDfd, store, syncDfd;
    store = model.store || model.collection.store;
    syncDfd = $.Deferred();
    try {
      switch (method) {
        case "read":
          respDfd = store.fetch(model, options);
          break;
        case "create":
          respDfd = store.saveChanges(model, options);
          break;
        case "update":
          respDfd = store.saveChanges(model, options);
          break;
        case "delete":
          respDfd = store.destroy(model, options);
      }
    } catch (_error) {
      error = _error;
      errorMessage = error.message;
    }
    if (respDfd) {
      respDfd.done(function(response, event) {
        if (options && options.success) {
          options.success(response);
        }
        return syncDfd.resolve(response, event);
      }).fail(function(error, event) {
        if (options && options.error) {
          options.error(error);
        }
        return syncDfd.reject(error);
      });
    } else {
      errorMessage = errorMessage ? errorMessage || "Record Not Found" : void 0;
      if (options && options.error) {
        options.error(errorMessage);
      }
      syncDfd.reject(errorMessage);
    }
    return syncDfd.promise();
  };
  Backbone.ajaxSync = Backbone.sync;
  Backbone.getSyncMethod = function(model) {
    if (model.store || (model.collection && model.collection.store)) {
      return Backbone.localSync;
    } else {
      return Backbone.ajaxSync;
    }
  };
  Backbone.sync = function(method, model, options) {
    return Backbone.getSyncMethod(model).apply(this, [method, model, options]);
  };
  return Backbone.IndexedDB;
});