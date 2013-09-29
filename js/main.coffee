'use strict'
require.config
	paths:
		jquery: 'lib/jquery-2.0.3.min'
		underscore: 'lib/underscore-min'
		backbone: 'lib/backbone-min'
		bootstrap: 'lib/bootstrap.min'
		text: 'lib/text'
		store: 'lib/backbone.localStorage-min'
		moment: 'lib/moment.min'
		'jQuery.scrollUp': 'lib/jquery.scrollUp.min'
		'jQuery.indexedDB': 'lib/jquery.indexeddb.min'
		messenger: 'lib/messenger.min'
		Dropbox: 'https://www.dropbox.com/static/api/dropbox-datastores-1.0-latest'
	shim:
		underscore:
			exports: '_'
		backbone:
			deps: [
				'underscore'
				'jquery'
			]
			exports: 'Backbone'
		bootstrap: ['jquery']
		store: ['backbone']
		'jQuery.scrollUp': ['jquery']
		'jQuery.indexedDB': ['jquery']
		messenger:
			deps: ['jquery']
			exports: 'Messenger'
		Dropbox:
			exports: 'Dropbox'

require [
	'jquery'
	'backbone'
	'views/app'
	'messenger'
	'bootstrap'
	'jQuery.scrollUp'
], ($, Backbone, appView, Messenger) ->
	$.scrollUp
		scrollDistance: 1
		scrollImg: true

	Messenger.options =
		extraClasses: 'messenger-fixed messenger-on-top'
		theme: 'air'

	updateOnlineStatus = ->
		options = showCloseButton: true
		if arguments[0].type == 'online'
			$.extend options,
				message: '上线状态'
				type: 'info'
		else
			$.extend options,
				message: '目前处于离线状态'
				type: 'error'
		Messenger().post options

	$(window).on 'online', updateOnlineStatus
	$(window).on 'offline', updateOnlineStatus

	new appView