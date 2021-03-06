// Generated by CoffeeScript 1.6.3
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(['underscore', 'backbone', 'moment'], function(_, Backbone, moment) {
  'use strict';
  var metaData, selectExpend, targetDate;
  selectExpend = function(element) {
    var event;
    event = document.createEvent('MouseEvents');
    event.initMouseEvent('mousedown', true, true, window);
    return element.dispatchEvent(event);
  };
  metaData = {
    categories: [
      {
        text: '-',
        value: void 0
      }, {
        text: '常规款',
        value: 0,
        details: [
          {
            text: '-',
            value: void 0
          }, {
            text: '水款',
            value: 0
          }, {
            text: '票款',
            value: 1
          }, {
            text: '押桶',
            value: 2
          }, {
            text: '退桶',
            value: 3
          }
        ]
      }, {
        text: '票',
        value: 1,
        details: [
          {
            text: '矿物质',
            value: 0
          }, {
            text: '纯净水',
            value: 1
          }, {
            text: '九龙山水',
            value: 2
          }, {
            text: '弱碱性',
            value: 3
          }
        ]
      }, {
        text: '销售款',
        value: 2,
        details: [
          {
            text: '饮水机[万爱]',
            value: 0
          }, {
            text: '饮水机[华生]',
            value: 1
          }, {
            text: '饮水机[长城]',
            value: 2
          }, {
            text: '饮水机[东瀛]',
            value: 3
          }, {
            text: '压水器',
            value: 4
          }, {
            text: '小水箱费',
            value: 5
          }
        ]
      }
    ],
    workers: [
      {
        text: '店内',
        value: 0
      }, {
        text: '老金',
        value: 1
      }, {
        text: '小华',
        value: 2
      }, {
        text: '陆德其',
        value: 3
      }, {
        text: '陈国伟',
        value: 4
      }
    ]
  };
  targetDate = _.extend({
    $el: $('#target-date').on('change', function() {
      if (!targetDate.$el.val()) {
        return;
      }
      targetDate.date = moment(targetDate.$el.val()).toDate();
      return targetDate.trigger('change', targetDate.date);
    }).val(moment().format("YYYY-MM-DD"))
  }, Backbone.Events);
  return new ((function() {
    function _Class() {
      this.getWorker = __bind(this.getWorker, this);
      this.getWorkers = __bind(this.getWorkers, this);
      this.getDetail = __bind(this.getDetail, this);
      this.getDetails = __bind(this.getDetails, this);
      this.getCategory = __bind(this.getCategory, this);
      this.getCategories = __bind(this.getCategories, this);
    }

    _Class.prototype.getCategories = function() {
      return metaData.categories;
    };

    _Class.prototype.getCategory = function(value) {
      return _.findWhere(metaData.categories, {
        value: value
      });
    };

    _Class.prototype.getDetails = function(categoryValue) {
      return (this.getCategory(categoryValue) || {}).details;
    };

    _Class.prototype.getDetail = function(categoryValue, detailValue) {
      var details;
      details = this.getDetails(categoryValue);
      if (!details) {
        return;
      }
      return _.findWhere(details, {
        value: detailValue
      });
    };

    _Class.prototype.getWorkers = function() {
      return metaData.workers;
    };

    _Class.prototype.getWorker = function(value) {
      return _.findWhere(metaData.workers, {
        value: value
      });
    };

    _Class.prototype.targetDate = targetDate;

    _Class.prototype.selectExpend = selectExpend;

    return _Class;

  })());
});
