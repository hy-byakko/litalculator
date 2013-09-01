// Generated by CoffeeScript 1.6.3
define(['underscore', 'backbone', 'models/post'], function(_, Backbone, Post) {
  'use strict';
  return new (Backbone.Collection.extend({
    model: Post,
    url: '/posts',
    index: function() {
      this.deactive();
      return this.render();
    },
    show: function(id) {
      this.active(id);
      return this.render();
    },
    render: function() {
      return this.trigger('render');
    },
    changeContent: function(content) {
      this.currentContent = content;
      return this.trigger('contentChange', content);
    },
    active: function(activeId) {
      this.activeId = activeId;
      return this.getContent();
    },
    deactive: function(activeId) {
      this.activeId = activeId != null ? activeId : void 0;
    },
    getContent: function() {
      var currentPost,
        _this = this;
      currentPost = this.currentPost();
      if (!currentPost) {
        return this.listenToOnce(this, 'reset', this.getContent);
      }
      if (currentPost.htmlContent) {
        return this.changeContent(currentPost.htmlContent);
      } else {
        this.ready = false;
        return currentPost.getHtml(function() {
          _this.ready = true;
          _this.changeContent(currentPost.htmlContent);
          return _this.render();
        });
      }
    },
    currentPost: function() {
      return this.get(this.activeId);
    },
    currentIndex: function() {
      return this.indexOf(this.currentPost());
    },
    offsetPost: function(offset) {
      var index;
      index = this.currentIndex() + offset;
      if (index > -1 && index < this.size()) {
        return this.at(index);
      }
    },
    getTags: function() {
      var _this = this;
      if (!this.tagCollection) {
        this.tagCollection = [];
        this.each(function(post) {
          if (post.get('tags')) {
            return _this.tagCollection = _.union(_this.tagCollection, post.getTags());
          }
        });
      }
      return this.tagCollection;
    },
    load: function() {
      var _this = this;
      return this.fetch({
        reset: true,
        complete: function() {
          _this.ready = true;
          return _this.render();
        }
      });
    }
  }));
});
