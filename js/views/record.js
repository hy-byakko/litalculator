// Generated by CoffeeScript 1.6.3
define(['jquery', 'underscore', 'backbone', 'common'], function($, _, Backbone, Common) {
  'use strict';
  return Backbone.View.extend({
    tagName: 'tr',
    events: {
      'click td.editable': 'switchToEdit',
      'blur select': 'editEnd',
      'blur [data-prop="num"] input': 'numEdit',
      'click button.close': 'removeRecord'
    },
    initialize: function() {
      this.listenTo(this.model, 'sync', this.render);
      return this.listenTo(this.model, 'destroy', this.remove);
    },
    indexBarTemplate: _.template('\
<td class="editable" data-prop="category"><%= model.categoryName() || "-" %></td>\
<td <% if(model.detailEditable()) { %>class="editable"<% } %> data-prop="detail"><%= model.detailName() || "-"  %></td>\
<td class="editable" data-prop="worker"><%= model.workerName() || "-"  %></td>\
<td class="editable" data-prop="num"><%= model.get("num") || "-" %> <%= model.get("category") == 1 ? "张" : "元" %></td>\
<td><button type="button" class="close">&times;</button></td>\
', void 0, {
      variable: 'model'
    }),
    render: function() {
      this.$el.html(this.indexBarTemplate(this.model));
      return this;
    },
    switchToEdit: function() {
      var $element, detailSelect, numInput, parent;
      parent = this.options.parent;
      $element = $(arguments[0].target);
      switch ($element.data("prop")) {
        case "category":
          $element.addClass('editor-wrap').empty().append(parent.$categorySelect);
          return parent.$categorySelect.val(this.model.get('category')).focus();
        case "detail":
          detailSelect = parent.detailSelectBuilder(this.model.get('category'));
          if (!detailSelect) {
            return;
          }
          $element.addClass('editor-wrap').empty().append(detailSelect);
          return detailSelect.val(this.model.get('detail')).focus();
        case "worker":
          $element.addClass('editor-wrap').empty().append(parent.$workerSelect);
          return parent.$workerSelect.val(this.model.get('worker')).focus();
        case "num":
          numInput = parent.numberBuilder({
            unit: this.model.get('category') === 1 ? '桶' : '元'
          });
          $element.addClass('editor-wrap').empty().append(numInput);
          return numInput.val(this.model.get('num')).focus();
      }
    },
    editEnd: function() {
      var $element, $wrap, newValue;
      $element = $(arguments[0].target);
      $wrap = $element.parent('td');
      newValue = _.isNaN(parseInt($element.val())) ? void 0 : parseInt($element.val());
      this.model.set($wrap.data("prop"), newValue);
      return this.model.save();
    },
    numEdit: function() {
      var $element, $wrap;
      $element = $(arguments[0].target);
      $wrap = $element.parent('td');
      if ($wrap.data("prop") !== 'num') {
        return;
      }
      this.model.setNum($element.val());
      return this.model.save();
    },
    removeRecord: function() {
      return this.model.destroy();
    }
  });
});
