define [
	'jquery'
	'underscore'
	'backbone'
	'models/recordcontainer'
	'collections/records'
	'common'
	'moment'
	'backbone.indexedDB'
], ($, _, Backbone, RecordContainer, Records, Common, moment) ->
	'use strict'

	Backbone.Collection.extend
		model: RecordContainer

		store: new Backbone.IndexedDB.Store 'recordContainers'

		# TODO Glodal event
		initialize: ->
			@records = new Records

			@listenTo @records, 'write', @recordsUpdate
			@listenTo Common.targetDate, 'change', =>
				do @recordsFetch
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

		recordsUpdate: ->
			container = @getContainer()
			container.set('content', JSON.stringify(@records.toJSON()))
			container.set('lastModifyTime', (new Date).toString())
			container.save()

		recordsFetch: ->
			@records.reset(JSON.parse(@getContainer().get('content')))
