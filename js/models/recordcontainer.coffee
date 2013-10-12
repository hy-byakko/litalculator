define [
	'jquery'
	'underscore'
	'backbone'
], ($, _, Backbone) ->
	'use strict'

	Backbone.Model.extend
		defaults: ->
			createTime: new Date
			lastModifyTime: new Date
			lastSyncTime: undefined
			contentTime: undefined
			content: []

		toRemoteFormat: ->
			recCntr = @toJSON()
			recCntr.content = JSON.stringify recCntr.content
			recCntr