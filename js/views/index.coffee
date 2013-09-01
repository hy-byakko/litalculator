define [
	'jquery'
	'underscore'
	'backbone'
	'collections/posts'
	'text!templates/index/bar.html'
], ($, _, Backbone, posts, bar) ->
	'use strict'

	Backbone.View.extend
		tagName: 'div'
		id: 'index_content'
		className: 'inner'

		indexBarTemplate: _.template bar

		initialize: ->
			# Fetch success will trigger reset
			posts.on 'reset', @renderIndex, @

		renderIndex: ->
			@$el.empty()
			posts.each (post) =>
				bar = $ $.parseHTML(@indexBarTemplate
					title: post.get('title')
					link: post.getLink()
					time: post.getTime().toLocaleDateString()
				)[0]

				_.each post.getTags(), (tag) =>
					bar.append @options.tagLinkTemplate({
						name: tag
						link: '#/tags/' + tag
					})
				@$el.append(bar)