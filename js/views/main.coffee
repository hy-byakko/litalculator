define [
	'jquery'
	'underscore'
	'backbone'
	'collections/posts'
	'routers/router'
	'text!templates/main/switcher.html'
], ($, _, Backbone, posts, router, switcher) ->
	'use strict'

	Backbone.View.extend
		events:
			'click #page-switcher-pre': 'preSwitch'
			'click #page-switcher-next': 'nextSwitch'

		switcherTemplate: _.template switcher

		initialize: ->
			@$el.append @switcherTemplate
				location: 'left',
				content: '‹',
				id: 'pre'

			@$el.append @switcherTemplate
				location: 'right',
				content: '›',
				id: 'next'

			@$el.append '<section class="inner" id="main_content" />'

			@$preSwitcher = @$('#page-switcher-pre')
			@$nextSwitcher = @$('#page-switcher-next')
			@$content = @$('#main_content')

			posts.on 'contentChange', @contentRender, @

		render: ->
			@$preSwitcher.toggle !!posts.offsetPost(-1)
			@$nextSwitcher.toggle !!posts.offsetPost(1)
			@

		contentRender: (content) ->
			@$content.html content

		preSwitch: ->
			router.navigate '//posts/' + posts.offsetPost(-1).get('id')

		nextSwitch: ->
			router.navigate '//posts/' + posts.offsetPost(1).get('id')
