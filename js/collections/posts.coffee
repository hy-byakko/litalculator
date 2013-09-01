define [
	'underscore'
	'backbone'
	'models/post'
], (_, Backbone, Post) ->
	'use strict'

	new (Backbone.Collection.extend
		model: Post
		url: '/posts'
		index: ->
			@deactive()
			@render()

		show: (id) ->
			@active(id)
			@render()

		render: ->
			@trigger('render')

		changeContent: (content) ->
			@currentContent = content
			@trigger('contentChange', content)

		active: (@activeId) ->
			@getContent()

		deactive: (@activeId = undefined) ->

		getContent: ->
			currentPost = @currentPost()

			# Ensure posts has fetched
			return @listenToOnce @, 'reset', @getContent unless currentPost

			if currentPost.htmlContent
				@changeContent currentPost.htmlContent
			else
				@ready = false
				currentPost.getHtml =>
					@ready = true
					@changeContent currentPost.htmlContent
					@render()

		currentPost: ->
			@get @activeId

		currentIndex: ->
			@indexOf @currentPost()

		offsetPost: (offset) ->
			index = @currentIndex() + offset
			@at(index) if index > -1 and index < @size()

		getTags: ->
			if !@tagCollection
				@tagCollection = []
				@each (post) =>
					@tagCollection = _.union @tagCollection, post.getTags() if post.get('tags')
			@tagCollection

		load: ->
			@fetch
				reset: true
				complete: =>
					@ready = true
					# Change mode
					@render()
	)