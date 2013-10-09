define [
	'jquery'
	'underscore'
	'backbone'
	'models/recordcontainer'
	'common'
	'moment'
	'backbone.indexedDB'
], ($, _, Backbone, RecordContainer, Common, moment) ->
	'use strict'

	Backbone.Collection.extend
		model: RecordContainer

		store: new Backbone.IndexedDB.Store 'recordContainers'

		initialize: ->
			# @listenTo Common.targetDate, 'change', =>
			# 	@trigger('filter')
			@

		# TODO Cache container
		getContainer: ->
			container = @find (container) ->
				moment(container.getTime('contentTime')).isSame(Common.targetDate.date)
			return container if container
			container = new RecordContainer
			container.set('contentTime', (Common.targetDate.date).toString())
			@add(container)
			container.save()
			container
