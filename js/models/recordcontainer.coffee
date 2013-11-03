define [
	'jquery'
	'underscore'
	'backbone'
	'common'
	'dropboxprovider'
], ($, _, Backbone, common, DropboxProvider) ->
	'use strict'

	Backbone.Model.extend
		defaults: ->
			createTime: new Date
			modifyTime: new Date
			contentTime: undefined
			content: []

		remote:
			table: 'recordContainers'
			key: 'contentTime'

		toRemoteFormat: ->
			recCntr = @toJSON()
			recCntr.content = JSON.stringify recCntr.content
			delete recCntr.id
			recCntr

		toLocalFormat: (recCntr) ->
			recCntr.content = JSON.parse recCntr.content
			recCntr