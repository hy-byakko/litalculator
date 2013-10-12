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
			contentTime: undefined
			content: []

		toRemoteFormat: ->
			recCntr = @toJSON()
			recCntr.content = JSON.stringify recCntr.content
			delete recCntr.id
			recCntr

		fetchRemote: (recCntr) ->
			recCntr.content = JSON.parse recCntr.content
			@save(recCntr)
