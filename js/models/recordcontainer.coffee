define [
	'jquery'
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	'use strict'

	Backbone.Model.extend
		defaults: ->
			createTime: (new Date).toString()
			lastModifyTime: (new Date).toString()
			lastSyncTime: undefined
			contentTime: undefined
			content: JSON.stringify []

		getTime: (name) ->
			new Date(@get(name))