'use strict'
require.config
	paths:
		jquery: 'lib/jquery-2.0.3.min'
		underscore: 'lib/underscore-min'
		backbone: 'lib/backbone-min'
		bootstrap: 'lib/bootstrap.min'
		text: 'lib/text'
		store: 'lib/backbone.localStorage-min'
		moment: "lib/moment.min",
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

require [
	'jquery'
	'backbone'
	'views/app'
], ($, Backbone, appView) ->
	new appView